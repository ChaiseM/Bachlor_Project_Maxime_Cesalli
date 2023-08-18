ARCHITECTURE test OF lcdSerializer_tester IS

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';

  constant initializationSequenceLength: positive := 14;
  type initializtionDataType is array (1 to initializationSequenceLength)
    of std_ulogic_vector(data'range);
  constant initializtionData: initializtionDataType :=(
    '0' & X"40",    -- Display start line 0
    '0' & X"A1",    -- 
    '0' & X"C0",    -- 
    '0' & X"A6",    -- 
    '0' & X"A2",    -- 
    '0' & X"2F",    -- 
    '0' & X"F8",    -- 
    '0' & X"00",    -- 
    '0' & X"23",    -- 
    '0' & X"81",    -- 
    '0' & X"1F",    -- 
    '0' & X"AC",    -- 
    '0' & X"00",    -- 
    '0' & X"AF"     -- 
  );

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                -- send sequence
  process
  begin
    data <= (others => '0');
    send <= '0';
    wait until falling_edge(busy);
                                                    -- send initialization codes
    wait until rising_edge(clock_int);
    for index in initializtionData'range loop
      data <= initializtionData(index);
      send <= '1', '0' after clockPeriod;
      wait until rising_edge(busy);
      wait until falling_edge(busy);
      wait for 1 ns;
    end loop;
    wait for 100*clockPeriod;
                                                             -- send pixel codes
    wait until rising_edge(clock_int);
    for index in 1 to 8 loop
      data <= std_ulogic_vector(to_unsigned(index, data'length));
      data(data'high) <= '1';
      send <= '1', '0' after clockPeriod;
      wait until rising_edge(busy);
      wait until falling_edge(busy);
      wait for 1 ns;
    end loop;
    wait for 100*clockPeriod;
                                                            -- end of simulation
    assert false
      report "End of simulation"
      severity failure;
    wait;
  end process;

END ARCHITECTURE test;
