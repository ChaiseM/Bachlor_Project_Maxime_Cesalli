library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF adc128S102Controller IS
                                                                    -- SPI clock
  constant spiDividerCount : positive
  	:= integer(clockFrequency/spiFrequency/2.0);
  constant spiDividerBitNb : positive := requiredBitNb(spiDividerCount);
  signal spiDividerCounter : unsigned(spiDividerBitNb-1 DOWNTO 0);
  signal spiClockEn : std_ulogic;
  signal spiClock : std_ulogic;
                                     -- ADC single channel acquisition sequencer
  constant adcSequenceEnd : positive := 2*16 + 3; 
  constant adcSequenceLength : positive := adcSequenceEnd + 2*2; 
  signal adcSequenceCounter : unsigned(
    requiredBitNb(adcSequenceLength)-1 DOWNTO 0
  );
  signal startSingle, doneSingle : std_ulogic;
  signal startSingleDelayed : std_ulogic;
  signal spiEn : std_ulogic;
                                           -- ADC complete acquisition sequencer
  constant channelNb : positive := 8; 
  signal adcChannelCounter : unsigned(
    requiredBitNb(channelNb-1)-1 DOWNTO 0
  );
  signal channelIdShiftRegister : unsigned(adcChannelCounter'high+3 DOWNTO 0);
                                                               -- ADC value read
  signal valueShitRegister : unsigned(adcBitNb-1 DOWNTO 0);
  subtype sampleType is unsigned(sample0'range);
  type sampleArrayType is array (0 to channelNb-1) of sampleType;
  signal sampleArray : sampleArrayType;

BEGIN

  ------------------------------------------------------------------------------
                                                                    -- SPI clock
  buildSpiSawtooth: process(reset, clock)
  begin
    if reset = '1' then
      spiDividerCounter <= (others => '0');
    elsif rising_edge(clock) then
      if spiClockEn = '1' then
        spiDividerCounter <= to_unsigned(
          spiDividerCount-1, spiDividerCounter'length
        );
      else
        spiDividerCounter <= spiDividerCounter - 1;
      end if;
    end if;
  end process buildSpiSawtooth;

  spiClockEn <= '1' when spiDividerCounter = 0
    else '0';

  buildSpiClock: process(reset, clock)
  begin
    if reset = '1' then
      spiClock <= '0';
    elsif rising_edge(clock) then
      if spiClockEn = '1' then
        spiClock <= not spiClock;
      end if;
    end if;
  end process buildSpiClock;

  ------------------------------------------------------------------------------
                                     -- ADC single channel acquisition sequencer
  countSingleSequence: process(reset,clock)
  begin
    if reset = '1' then
      adcSequenceCounter <= (others => '0');
    elsif rising_edge(clock) then
      if startSingle = '1' then
        adcSequenceCounter <= to_unsigned(1, adcSequenceCounter'length);
      elsif spiClockEn = '1' then
        if adcSequenceCounter = 1 then
          if spiClock = '0' then
            adcSequenceCounter <= adcSequenceCounter + 1;
          end if;
        elsif adcSequenceCounter = adcSequenceLength then
          adcSequenceCounter <= (others => '0');
        elsif adcSequenceCounter > 0 then
          adcSequenceCounter <= adcSequenceCounter + 1;
        end if;
      end if;
    end if;
  end process countSingleSequence;

  doneSingle <= '1' when
    (adcSequenceCounter = adcSequenceLength) and (spiClockEn = '1')
    else '0';
  spiEn <= '1' when
    (1 < adcSequenceCounter) and (adcSequenceCounter < adcSequenceEnd)
    else '0';
  CS_n <= not spiEn;
  SCLK <= spiClock when
    (adcSequenceCounter > 2) and (adcSequenceCounter < adcSequenceEnd-1)
    else '1';

  ------------------------------------------------------------------------------
                                           -- ADC complete acquisition sequencer
  countAllSequences: process(reset,clock)
  begin
    if reset = '1' then
      adcChannelCounter <= (others => '0');
    elsif rising_edge(clock) then
      if adcChannelCounter = 0 then
        if sampleEn = '1' then
          adcChannelCounter <= to_unsigned(
            channelNb-1, adcChannelCounter'length
          );
        end if;
      else
        if doneSingle = '1' then
          adcChannelCounter <= adcChannelCounter - 1;
        end if;
      end if;
    end if;
  end process countAllSequences;

  startSingle <= '1' when sampleEn = '1'
    else doneSingle when adcChannelCounter > 0
    else '0';

  provideChannelId: process(reset,clock)
  begin
    if reset = '1' then
      startSingleDelayed <= '0';
      channelIdShiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      startSingleDelayed <= startSingle;
      if startSingleDelayed = '1' then
        channelIdShiftRegister <= resize(
          adcChannelCounter, channelIdShiftRegister'length
        );
      elsif (spiClockEn = '1') and (spiClock = '0') then
        channelIdShiftRegister <= shift_left(channelIdShiftRegister, 1);
      end if;
    end if;
  end process provideChannelId;

  DIN <= channelIdShiftRegister(channelIdShiftRegister'high);

  ------------------------------------------------------------------------------
                                                     -- ADC value shift register
  shiftAdcValue: process(reset,clock)
  begin
    if reset = '1' then
      valueShitRegister <= (others => '0');
    elsif rising_edge(clock) then
      if (spiClockEn = '1') and (spiClock = '1') then
        valueShitRegister <= shift_left(valueShitRegister, 1);
        valueShitRegister(0) <= DOUT;
      end if;
    end if;
  end process shiftAdcValue;
                                                     -- ADC value shift register
  storeAdcValue: process(reset,clock)
  begin
    if reset = '1' then
      sampleArray <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if (spiClockEn = '1') and (adcSequenceCounter = adcSequenceEnd) then
        sampleArray(to_integer(adcChannelCounter)) <= valueShitRegister;
      end if;
    end if;
  end process storeAdcValue;

  ------------------------------------------------------------------------------
                                                                      -- Outputs
  sample0 <= sampleArray(0);
  sample1 <= sampleArray(1);
  sample2 <= sampleArray(2);
  sample3 <= sampleArray(3);
  sample4 <= sampleArray(4);
  sample5 <= sampleArray(5);
  sample6 <= sampleArray(6);
  sample7 <= sampleArray(7);

END ARCHITECTURE RTL;
