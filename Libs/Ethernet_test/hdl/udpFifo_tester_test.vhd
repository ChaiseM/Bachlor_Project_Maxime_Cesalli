ARCHITECTURE test OF udpFifo_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';
  signal reset_int: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- Reset and clock
  reset_int <= '1', '0' after 2*clockPeriod;
  reset <= reset_int;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                          -- send frame from RAM
  process
  begin
    sendDiscardFrame <= '0';
    
    wait for 1 us;
    sendDiscardFrame <= '1', '0' after 100*clockPeriod;

    wait for 33 us - now;
    sendDiscardFrame <= '1', '0' after 100*clockPeriod;

    wait;
  end process;

END ARCHITECTURE test;
