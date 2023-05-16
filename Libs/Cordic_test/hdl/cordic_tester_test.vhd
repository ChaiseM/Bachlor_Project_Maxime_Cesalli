ARCHITECTURE test OF sinCosSequential_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal start_int: std_uLogic := '0';
  signal phase_int: unsigned(phase'range) := (others => '0');
  signal sine_int: signed(sine'range);
  signal cosine_int: signed(cosine'range);

BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clocks
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------

  start_int <= '0' after clockPeriod when start_int = '1' else '1' after 20*clockPeriod;
  start <= start_int;

  countPhase: process(done)
  begin
    if falling_edge(done) then
      phase_int <= phase_int + 1 after clockPeriod;
    end if;
  end process countPhase;

  phase <= phase_int;

  sine_int <= sine when done = '1' else sine_int;
  cosine_int <= cosine when done = '1' else cosine_int;

END ARCHITECTURE test;
