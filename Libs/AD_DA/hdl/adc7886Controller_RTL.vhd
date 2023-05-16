ARCHITECTURE RTL OF adc7886Controller IS

                                                                    -- SPI clock
  signal sclk_int : std_ulogic;
                                                                       -- SPI CS
  constant spiClockNb : positive := 16;
  signal countCsLength : unsigned(spiClockNb+1-1 downto 0);
  signal cs_int : std_ulogic;
                                                   -- SPI data in shift register
  signal dataIn : unsigned(amplitude'range);

BEGIN
                                                                    -- SPI clock
  buildFreeRunningClock: process(reset, clock)
  begin
    if reset = '1' then
      sclk_int <= '0';
    elsif rising_edge(clock) then
      if sclkEn = '1' then
        sclk_int <= not sclk_int;
      end if;
    end if;
  end process buildFreeRunningClock;

  SCLK <= sclk_int;
                                                                       -- SPI CS
  buildCs: process(reset, clock)
  begin
    if reset = '1' then
      countCsLength <= (others => '0');
    elsif rising_edge(clock) then
      if startConv = '1' then
        countCsLength(countCsLength'high) <= '1';
      elsif (sclkEn = '1') and (sclk_int = '0') then
        countCsLength <= shift_right(countCsLength, 1);
      end if;
    end if;
  end process buildCs;

  cs_int <= '1' when countCsLength(countCsLength'high-1 downto 0) /= 0
    else '0';
  CS_n <= not cs_int;
                                                   -- SPI data in shift register
  shiftDataIn: process(reset, clock)
  begin
    if reset = '1' then
      dataIn <= (others => '0');
    elsif rising_edge(clock) then
      if (sclkEn = '1') and (sclk_int = '0') and (cs_int = '1') then
        dataIn <= shift_left(dataIn, 1);
        dataIn(0) <= SDO;
      end if;
    end if;
  end process shiftDataIn;

  storeSample: process(reset, clock)
  begin
    if reset = '1' then
      amplitude <= (others => '0');
    elsif rising_edge(clock) then
      if (sclkEn = '1') and (sclk_int = '1') and (countCsLength(0) = '1') then
        amplitude <= dataIn;
      end if;
    end if;
  end process storeSample;


END ARCHITECTURE RTL;
