library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc7760 IS

  constant dataDelay: time := 11 ns;

  constant drdyPeriod: positive := 2**5;
  signal drdyCounter: natural := 0;
  signal drdy_int: std_ulogic;

  signal vinSampled: signed(adcBitNb-1 downto 0);
  signal DB_int: signed(DB'range);

  signal selHigh: boolean;

BEGIN

  ------------------------------------------------------------------------------
                                                                  -- DRDY signal
  process(RESET_n, MCLK)
  begin
    if RESET_n = not'1' then
      drdyCounter <= 0;
    elsif rising_edge(MCLK) then
      if drdyCounter >= drdyPeriod-1 then
        drdyCounter <= 0;
      else
        drdyCounter <= drdyCounter + 1;
      end if;
    end if;
  end process;

  drdy_int <= '1' when drdyCounter = 0
    else '0';

  DRDY_n <= not drdy_int;

  ------------------------------------------------------------------------------
                                                          -- sample input signal
  sampleSignal: process(drdy_int)
  begin
    if falling_edge(drdy_int) then
      vinSampled <= to_signed(VIN, vinSampled'length);
    end if;
  end process sampleSignal;

  ------------------------------------------------------------------------------
                                                             -- select data bits
  invertWordSelection: process(RESET_n, drdy_int, CS_n)
  begin
    if RESET_n = not '1' then
      selHigh <= TRUE;
    elsif drdy_int = '1' then
      selHigh <= TRUE;
    elsif rising_edge(CS_n) then
      selHigh <= FALSE;
    end if;
  end process invertWordSelection;

  ------------------------------------------------------------------------------
                                                             -- drive Data lines
  dirveData: process(CS_n, WR_RD_n)
  begin
    if CS_n = not '0' then
      DB_int <= (others => 'Z') after dataDelay;
    else
      if WR_RD_n = not '1' then
        if selHigh then
          DB_int <= vinSampled(vinSampled'high downto vinSampled'high-DB'length+1);
        else
          DB_int(DB'high downto vinSampled'length-DB'length) <=
            vinSampled(vinSampled'length-DB'length-1 downto 0);
          DB_int(vinSampled'length-DB'length-1 downto 0) <= (others => '0');
        end if;
      else
        DB_int <= (others => 'Z');
      end if;
    end if;
  end process dirveData;

  DB <= DB_int after dataDelay;

END ARCHITECTURE sim;
