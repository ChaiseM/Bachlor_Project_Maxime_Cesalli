ARCHITECTURE RTL OF mii_resetSynch IS
BEGIN

  process(reset, rx_clock)
  begin
    if reset = '1' then
      rx_reset <= '1';
    elsif rising_edge(rx_clock) then
      rx_reset <= '0';
    end if;
  end process;

END ARCHITECTURE RTL;
