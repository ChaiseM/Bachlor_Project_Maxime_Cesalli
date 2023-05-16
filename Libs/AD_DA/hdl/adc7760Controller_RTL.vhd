library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF adc7760Controller IS

  signal mclkCounter: unsigned(requiredBitNb(mclkDivide)-1 downto 0);
  signal mclkRise, mclkFall: std_ulogic;
  signal mclk_int: std_ulogic;

  signal writeCounter: unsigned(1 downto 0);
  signal mclkRise4: std_ulogic;
  signal resetShiftReg: std_ulogic_vector(11 downto 0);
  signal endOfReset: std_ulogic;
  signal dbWrite: unsigned(DB'range);

  signal csRead, csWrite: std_ulogic_vector(CS_n'range);

  signal readShiftReg: std_ulogic_vector(4*adcNb downto 0);
  signal readAccess: std_ulogic;

  subtype amplitudeType is signed(amplitude1'range);
  type amplitudeArrayType is array(adcNb-1 downto 0) of amplitudeType;
  signal amplitudeReg: amplitudeArrayType;
  signal sampleWait, sampleDone: std_ulogic;

BEGIN

  ------------------------------------------------------------------------------
                                                           -- enable for timings
  countMclk: process(reset, clock)
  begin
    if reset = '1' then
      mclkCounter <= (others => '0');
    elsif rising_edge(clock) then
      if mclkCounter < mclkDivide-1 then
        mclkCounter <= mclkCounter + 1;
      else
        mclkCounter <= (others => '0');
      end if;
    end if;
  end process countMclk;

  mclkRise <= '1' when mclkCounter = 0
    else '0';

  mclkFall <= '1' when mclkCounter = mclkDivide/2
    else '0';

  divideBy4: process(reset, clock)
  begin
    if reset = '1' then
      writeCounter <= (others => '0');
    elsif rising_edge(clock) then
      if mclkRise = '1' then
        writeCounter <= writeCounter + 1;
      end if;
    end if;
  end process divideBy4;

  mclkRise4 <= '1' when (writeCounter = 0) and (mclkRise = '1')
    else '0';

  ------------------------------------------------------------------------------
                                                             -- ADC master clock
  generateMclk: process(reset, clock)
  begin
    if reset = '1' then
      mclk_int <= '0';
    elsif rising_edge(clock) then
      if mclkRise = '1' then
        mclk_int <= '1';
      elsif mclkFall = '1' then
        mclk_int <= '0';
      end if;
    end if;
  end process generateMclk;

  MCLK <= mclk_int;

  ------------------------------------------------------------------------------
                                                               -- power-on reset
  buildPowerOnReset: process(reset, clock)
  begin
    if reset = '1' then
      resetShiftReg <= (0=> '1', others => '0');
    elsif rising_edge(clock) then
      if mclkRise4 = '1' then
        resetShiftReg(0) <= '0';
        resetShiftReg(resetShiftReg'high downto 1) <=
          resetShiftReg(resetShiftReg'high-1 downto 0);
      end if;
    end if;
  end process buildPowerOnReset;

  endOfReset <= '1' when unsigned(resetShiftReg) = 0
    else '0';

  RESET_n <= not '1' when resetShiftReg(1) = '1'
    else not '0';

  csWrite <= (others => '1') when
    (resetShiftReg(3) = '1') or (resetShiftReg(5) = '1') or
    (resetShiftReg(7) = '1') or (resetShiftReg(9) = '1')
    else (others => '0');

  buildRegisterWriteData: process(clock, reset)
  begin
    if reset = '1' then
      dbWrite <= (others => '0');
    elsif rising_edge(clock) then
      if (resetShiftReg(2) = '1') then
        dbWrite <= to_unsigned(1, dbWrite'length);
      elsif (resetShiftReg(4) = '1') then
        dbWrite <= to_unsigned(reg1Data, dbWrite'length);
      elsif resetShiftReg(6) = '1' then
        dbWrite <= to_unsigned(2, dbWrite'length);
      elsif (resetShiftReg(8) = '1') then
        dbWrite <= to_unsigned(reg2Data, dbWrite'length);
      elsif resetShiftReg(resetShiftReg'high) = '1' then
        dbWrite <= (others => '0');
      end if;
    end if;
  end process buildRegisterWriteData;

  SYNC_n <= not '1' when resetShiftReg(resetShiftReg'high) = '1'
    else not '0';

  ------------------------------------------------------------------------------
                                                                  -- read timing
  buildReadSignals: process(reset, clock)
  begin
    if reset = '1' then
      readShiftReg <= (others => '0');
    elsif rising_edge(clock) then
      if (DRDY_n = not '1') and (endOfReset = '1') then
        readShiftReg(0) <= '1';
      elsif (DRDY_n = not '0') and (mclkRise = '1') then
        readShiftReg(0) <= '0';
        readShiftReg(readShiftReg'high downto 1) <=
          readShiftReg(readShiftReg'high-1 downto 0);
      end if;
    end if;
  end process buildReadSignals;

  process(readShiftReg)
  begin
    for index in CS_n'range loop
      csRead(index) <= readShiftReg(4*index+1) or readShiftReg(4*index+3);
    end loop;
  end process;

  readAccess <= '1' when
    (unsigned(readShiftReg) /= 0) and (endOfReset = '1')
    else '0';
  WR_RD_n <=  not readAccess;

  ------------------------------------------------------------------------------
                                                                -- data sampling
  storeData: process(reset, clock)
  begin
    if reset = '1' then
      amplitudeReg <= (others => (others => '0'));
    elsif rising_edge(clock) then
      for index in amplitudeReg'range loop
        if readShiftReg(4*index+1) = '1' then
          amplitudeReg(index)(amplitude1'high downto amplitude1'length-DB'length) <= DB;
        elsif readShiftReg(4*index+3) = '1' then
          amplitudeReg(index)(amplitude1'high-DB'length downto 0) <=
            DB(DB'high downto amplitude1'length-DB'length);
        end if;
      end loop;
    end if;
  end process storeData;

  sampleData: process(reset, clock)
  begin
    if reset = '1' then
      sampleWait <= '0';
      sampleDone <= '0';
      amplitude1 <= (others => '0');
      amplitude2 <= (others => '0');
    elsif rising_edge(clock) then
      if newSample = '1' then
        sampleWait <= '1';
      end if;
      sampleDone <= '0';
      if sampleWait = '1' then
        if readAccess = '0' then
          sampleWait <= '0';
          sampleDone <= '1';
          amplitude1 <= amplitudeReg(0);
          amplitude2 <= amplitudeReg(1);
        end if;
      end if;
    end if;
  end process sampleData;

  ------------------------------------------------------------------------------
                                                                     -- data out
  DB <= (others => 'Z') when readAccess = '1'
    else signed(dbWrite);

  CS_n <= not (csRead or csWrite);

END ARCHITECTURE RTL;
