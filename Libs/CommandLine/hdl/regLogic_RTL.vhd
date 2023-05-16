ARCHITECTURE RTL OF regLogic IS

BEGIN

  updateRegister: process(reset, clock)
  begin
    if reset = '1' then
      regValue <= '0';
      enOut <= '0';
    elsif rising_edge(clock) then
      if en = '1' then
        regValue <= commandValue;
        enOut <= '1';
      else
        enOut <= '0';
      end if;
    end if;
  end process updateRegister;

END ARCHITECTURE RTL;
