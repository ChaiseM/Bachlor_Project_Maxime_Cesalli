LIBRARY Common;
USE Common.CommonLib.all;

architecture RTL of spiTimer is

  constant spiDivideCount : positive
    := integer(clockFrequency/(2.0*spiFrequency));

  signal spiPeriodCounter: unsigned(requiredBitNb(spiDivideCount)-1 downto 0);
  signal spiPeriodEnd: std_uLogic;

begin
  ------------------------------------------------------------------------------
                                                   -- count to SPI period length
  divideClock: process(reset, clock)
  begin
    if reset = '1' then
      spiPeriodCounter <= (others => '0');
    elsif rising_edge(clock) then
      if spiPeriodEnd = '1' then
        spiPeriodCounter <= (others => '0');
      else
        spiPeriodCounter <= spiPeriodCounter + 1;
      end if;
    end if;
  end process divideClock;

  spiPeriodEnd <= '1' when spiPeriodCounter >= spiDivideCount-1
    else '0';

  ------------------------------------------------------------------------------
                                                                -- assign output
  en2x <= spiPeriodEnd;

end RTL;
