ARCHITECTURE RTL OF sawtoothGenerator IS

  signal counter: unsigned(counterBitNb-1 downto 0);

BEGIN

  buildSawtooth: process(reset, clock)
  begin
    if reset = '1' then
      counter <= (others => '0');
    elsif rising_edge(clock) then
      counter <= counter + step;
    end if;
  end process buildSawtooth;

  sawtooth <= counter(counter'high downto counter'high-sawtoothBitNb+1);

END RTL;