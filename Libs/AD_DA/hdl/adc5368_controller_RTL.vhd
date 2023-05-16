ARCHITECTURE RTL OF adc5368_controller IS
                                                                -- configuration
  constant mclkDivider : positive := 4;
  signal dif: std_ulogic_vector(1 downto 0);
  signal div: std_ulogic_vector(3 downto 0);
  
  constant resetCounterBitNb: positive := 5;
  signal resetCounter: unsigned(resetCounterBitNb-1 DOWNTO 0);
  signal resetCounterDone: std_ulogic;
                                                                         -- MCLK
  signal ddsStep: unsigned(ddsBitNb-1 downto 0);
  signal ddsPhase: unsigned(ddsBitNb-1 downto 0);
                                                           -- serial to parallel
  constant channelNb : positive := 8; 
  subtype sampleRegType is signed(sample1'range);
  type sampleArrayType is array (1 to channelNb) of sampleRegType;

  signal sclk_delayed : std_ulogic;
  signal lrck_delayed : std_ulogic;
  signal sclk_rising : std_ulogic;
  signal lrck_changed : std_ulogic;
  signal bitCounter : unsigned(4 downto 0);  -- count to 32
  signal sdIn: std_ulogic_vector(1 to channelNb);
  signal samplesReg, samplesOut : sampleArrayType;
  signal sampleEn_int : std_ulogic;
                                                       -- test pattern generator
--  constant signalLength: positive := sample1'length;
  constant signalLength: positive := 24;
  signal testPrescalerCounter : unsigned(11 downto 0);
  signal sampleEn_test : std_ulogic;
  signal signalRamp : unsigned(signalLength+4-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
  -- This setup is for stand-alone mode with:
  --    * I2S serial audio interface format
  --    * MCLK divide set by generic parameter
  ------------------------------------------------------------------------------

                                                 -- I2S format (datasheet 4.5.3)
  dif <= "01";
                              -- clock dividers (datasheet 4.6.3)
                              --   bit 3: divide by 1 or by 1.5
                              --   bit 2: divide by 1 or by 2
                              --   bits 1-0: divide by 4 (00) , 2 (01) or 1 (10)
  div <= "0001" when mclkDivider = 2 
    else "0000" when mclkDivider = 4
    else "0100" when mclkDivider = 8
    else "0001";
                                                                  -- output bits
  dif1    <= dif(1);
  dif0    <= dif(0);
  clkmode <= div(3);
  mdiv    <= div(2);
  m1      <= div(1);
  m0      <= div(0);

  ------------------------------------------------------------------------------
                                                                    -- ADC reset
  countResetDuration: process(clock, reset)
  begin
    if reset = '1' then
      resetCounter <= (others => '0');
    elsif rising_edge(clock) then
      if init = '1' then
        resetCounter <= (others => '1');
      elsif resetCounterDone = '0' then
        resetCounter <= resetCounter + 1;
      end if;
    end if;
  end process countResetDuration;

  resetCounterDone <= '1' when signed(resetCounter) = -1
    else '0';

  rst_n <= '0' when resetCounterDone = '0'
    else '1';

  ------------------------------------------------------------------------------
                                                                     -- MCLK DDS
  ddsStep <= to_unsigned(
    integer(
      2.0**ddsStep'length * samplingFrequency / clockFrequency
      * real(mclkDivider) * 64.0
    ),
    ddsStep'length
  );

  buildSawtooth: process(reset, clock)
  begin
    if reset = '1' then
      ddsPhase <= (others => '0');
    elsif rising_edge(clock) then
      ddsPhase <= ddsPhase + ddsStep;
    end if;
  end process buildSawtooth;

  mclk <= ddsPhase(ddsPhase'high);

  ------------------------------------------------------------------------------
                                                             -- I2S deserializer
  delayClocks: process(reset, clock)
  begin
    if reset = '1' then
      sclk_delayed <= '0';
      lrck_delayed <= '0';
    elsif rising_edge(clock) then
      sclk_delayed <= sclk;
      lrck_delayed <= lrck;
    end if;
  end process delayClocks;

  sclk_rising <= '1' when (sclk = '1') and (sclk_delayed = '0') else '0';
  lrck_changed <= '1' when lrck_delayed /= lrck else '0';

  countBits: process(reset, clock)
  begin
    if reset = '1' then
      bitCounter <= (others => '0');
    elsif rising_edge(clock) then
      if lrck_changed = '1' then
        bitCounter <= (others => '0');
      elsif sclk_rising = '1' then 
        bitCounter <= bitCounter + 1;
      end if;
    end if;
  end process countBits;

  sdIn(1) <= sdout1;
  sdIn(2) <= sdout1;
  sdIn(3) <= sdout2;
  sdIn(4) <= sdout2;
  sdIn(5) <= sdout3;
  sdIn(6) <= sdout3;
  sdIn(7) <= sdout4;
  sdIn(8) <= sdout4;

  shiftRegisters: process(reset, clock)
  begin
    if reset = '1' then
      samplesReg <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if sclk_rising = '1' then
        if bitCounter < sampleRegType'length+1 and bitCounter > 0 then
          if lrck = '0' then -- odd channels arrive: 1,3,5,7
            for index in 0 to 3 loop
              samplesReg(2*index+1) <= shift_left(samplesReg(2*index+1), 1);
              samplesReg(2*index+1)(0) <= sdIn(2*index+1);
            end loop;
          else -- even channels arrive: 2,4,6,8
            for index in 1 to 4 loop
              samplesReg(2*index) <= shift_left(samplesReg(2*index), 1);
              samplesReg(2*index)(0) <= sdIn(2*index);
            end loop;
          end if;
        end if;
      end if;
    end if;
  end process shiftRegisters;

  outputData: process(reset, clock)
  begin
    if reset = '1' then
      samplesOut <= (others => (others => '0'));
      sampleEn_int <= '0';
    elsif rising_edge(clock) then
      if (lrck_changed = '1') and (lrck = '0') then
				sampleEn_int <= '1';
        for index in samplesOut'range loop
          samplesOut(index) <= shift_left(
            samplesReg(index) + inputOffset,
            inputShiftBitNb
          );
        end loop;
      else
        sampleEn_int <= '0';
      end if;
    end if;
  end process outputData;

  ------------------------------------------------------------------------------
                                                       -- Test pattern generator
  divideClock: process(reset, clock)
  begin
    if reset = '1' then
      testPrescalerCounter <= (others => '0');
    elsif rising_edge(clock) then
      testPrescalerCounter <= testPrescalerCounter + 1;
    end if;
  end process divideClock;

  sampleEn_test <= '1' when testPrescalerCounter = 0 else '0';

  countRamp: process(reset, clock)
  begin
    if reset = '1' then
      signalRamp <= (others => '0');
    elsif rising_edge(clock) then
      if sampleEn_test = '1' then
        signalRamp <= signalRamp + shift_left(
          resize("1", signalRamp'length),
          sample1'length-4
        );
      end if;
    end if;
  end process countRamp;

  ------------------------------------------------------------------------------
                                                           -- Output multiplexer
  sampleEn <= sampleEn_int when testMode = '0' else sampleEn_int;
  sample1 <= samplesOut(1) when testMode = '0'
    else shift_left(signed(signalRamp(sample1'range)), 1) when signalRamp(signalLength-1) = '0'
      else not(shift_left(signed(signalRamp(signalLength-1 downto 0)), 1));
  sample2 <= samplesOut(2) when testMode = '0'
    else (signalLength-1 => not signalRamp(signalLength-1) xor signalRamp(signalLength-2), others => signalRamp(sample1'high) xor signalRamp(sample1'high-1));
  sample3 <= samplesOut(3) when testMode = '0'
    else (others => '0');
  sample4 <= samplesOut(4) when testMode = '0'
    else (others => '0');
  sample5 <= samplesOut(5) when testMode = '0'
    else (others => '0');
  sample6 <= samplesOut(6) when testMode = '0'
    else (others => '0');
  sample7 <= samplesOut(7) when testMode = '0'
    else (others => '0');
  sample8 <= samplesOut(8) when testMode = '0'
    else (others => '0');

END ARCHITECTURE RTL;
