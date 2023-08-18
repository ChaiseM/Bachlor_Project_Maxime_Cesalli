ARCHITECTURE test OF sinCosPipelined_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal phase_int: unsigned(phase'range) := (others => '0');

BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clocks
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------

  countPhase: process(clock_int)
  begin
    if rising_edge(clock_int) then
      phase_int <= phase_int + 1;
    end if;
  end process countPhase;

  phase <= phase_int;

END ARCHITECTURE test;
