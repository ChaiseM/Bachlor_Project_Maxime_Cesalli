ARCHITECTURE RTL OF periodCounter IS

  signal counter: unsigned(counterBitNb-1 downto 0);
  signal countDone: std_ulogic;

BEGIN

  count: process(reset, clock)
  begin
    if reset = '1' then
      counter <= (others => '0');
    elsif rising_edge(clock) then
      if en = '1' then
        if countDone = '1' then
          counter <= period - 1;
        else
          counter <= counter - 1;
        end if;
      end if;
    end if;
  end process count;

  countDone <= '1' when counter = 0 else '0';
  done <= countDone;

END ARCHITECTURE RTL;
