ARCHITECTURE RTL OF interlock IS

BEGIN
  ------------------------------------------------------------------------------
                                                                    -- interlock
  updateSelection: process(reset, clock)
    variable inputActive: std_ulogic;
  begin
    if reset = '1' then
      selectEn <= (others => '0');
    elsif rising_edge(clock) then
      inputActive := '0';
      for index in selectPulses'range loop
        if selectPulses(index) = '1' then
          inputActive := '1';
        end if;
      end loop;
      if inputActive = '1' then
        selectEn <= (others => '0');
        for index in selectPulses'range loop
          selectEn(index) <= selectPulses(index);
        end loop;
      end if;
    end if;
  end process updateSelection;

END ARCHITECTURE RTL;
