ARCHITECTURE RTL OF udpApplRead IS

  signal dataValid: std_ulogic;
  signal instanceId: natural range 0 to selectedInstance'length;

BEGIN

  dataValid <= (not rxEmpty) and readEn(instanceId) when instanceId > 0
    else not rxEmpty;
  rxRd <= dataValid;
  udpDataValid <= dataValid;
  udpData <= rxData;

  findSelected: process(selectedInstance)
    variable instanceIndex : natural range 0 to selectedInstance'length;
  begin
    instanceIndex := 0;
    for index in selectedInstance'range loop
      if selectedInstance(index) = '1' then
        instanceIndex := index;
      end if;
    end loop;
    instanceId <= instanceIndex;
  end process findSelected;

END ARCHITECTURE RTL;
