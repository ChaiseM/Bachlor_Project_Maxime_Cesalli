ARCHITECTURE test OF dds_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';


  constant enPeriod: natural := 4;
  signal en_int: std_uLogic := '0';
  signal step_int: unsigned(step'range) := to_unsigned(1, step'length);

BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clocks
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                 -- count enable
  process
  begin
    en_int <= '0';
    for index in 1 to enPeriod-1 loop
      wait until rising_edge(clock_int);
    end loop;
    en_int <= '1';
    wait until rising_edge(clock_int);
  end process;

  en <= en_int;

  ------------------------------------------------------------------------------
                                                                  -- update step
  updateStep: process(clock_int)
  begin
    if rising_edge(clock_int) then
      if carry = '1' then
        step_int <= step_int + 1;
      end if;
    end if;
  end process updateStep;

  step <= step_int;

END ARCHITECTURE test;

