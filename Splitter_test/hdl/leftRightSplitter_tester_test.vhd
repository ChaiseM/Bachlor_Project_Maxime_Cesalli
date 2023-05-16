ARCHITECTURE test OF leftRightSplitter_tester IS
                                                              -- clock and reset
  constant clockPeriod: time := 1.0/clockFrequency * 1 sec;
  signal sClock: std_uLogic := '1';
  signal sReset: std_uLogic;

BEGIN
  ------------------------------------------------------------------------------
  -- clock and reset
  --
  sReset <= '1', '0' after 4*clockPeriod;
  reset <= sReset;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after 9.0/10.0 * clockPeriod;

END ARCHITECTURE test;
