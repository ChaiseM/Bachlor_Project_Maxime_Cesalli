ARCHITECTURE RTL OF synchUnsigned IS

BEGIN

  synchData: process(reset, clock)
  begin
    if reset = '1' then
      dataSynch <= (others => '0');
    elsif rising_edge(clock) then
      dataSynch <= dataIn;
    end if;
  end process synchData;

END ARCHITECTURE RTL;
