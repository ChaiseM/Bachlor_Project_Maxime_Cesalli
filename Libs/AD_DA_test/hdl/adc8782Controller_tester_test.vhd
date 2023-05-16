ARCHITECTURE test OF adc8782Controller_tester IS

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';

  constant samplingRate: real := 1.0E6;
  constant samplingPeriod: time := (1.0/samplingRate) * 1 sec;
  signal amplitude_int: natural;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
  begin
    amplitude_int <= 0;
                                                               -- write values
    for index in 1 to 20 loop
      wait for samplingPeriod;
      amplitude_int <= index;
    end loop;
                                                          -- end of simulation
    wait;
  end process;

  AINR <= amplitude_int;
  AINL <= 2*amplitude_int;

END ARCHITECTURE test;
