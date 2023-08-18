ARCHITECTURE test OF lcdController_tester IS

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';

  constant testInterval: time := 5 us;

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
    ascii <= (others => '0');
    send <= '0';
    wait until falling_edge(busy);
    wait for testInterval;
                                                        -- send single character
    wait until rising_edge(clock_int);
    ascii <= std_ulogic_vector(to_unsigned(character'pos('a'), ascii'length));
    send <= '1', '0' after clockPeriod;
    wait until rising_edge(busy);
    wait until falling_edge(busy);
    wait for testInterval;
                                                        -- send character stream
    for index in character'pos('b') to character'pos('d') loop
      ascii <= std_ulogic_vector(to_unsigned(index, ascii'length));
      send <= '1', '0' after clockPeriod;
      wait until rising_edge(busy);
      wait until falling_edge(busy);
      wait for 1 ns;
    end loop;
    wait for testInterval;
                                                            -- end of simulation
    assert false
      report "End of simulation"
      severity failure;
    wait;
  end process;

END ARCHITECTURE test;
