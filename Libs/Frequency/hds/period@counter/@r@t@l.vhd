architecture RTL of interpolatorTrigger is

  signal triggerCounter: unsigned(counterBitNb-1 downto 0);

begin

  count: process(reset, clock)
  begin
    if reset = '1' then
      triggerCounter <= (others => '0');
    elsif rising_edge(clock) then
      if en = '1' then
        triggerCounter <= triggerCounter + 1;
      end if;
    end if;
  end process count;

  trig: process(triggerCounter, en)
  begin
    if triggerCounter = 0 then
      triggerOut <= en;
    else
      triggerOut <= '0';
    end if;
  end process trig;

end RTL;
