LIBRARY std;
  USE std.textio.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE test OF ethernetFifo_tester IS
                                                              -- reset and clock
  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';
  signal reset_int: std_ulogic;
                                                                      -- Rx read
  constant pauseDelayPeriods: positive := 10;
  signal read_frames, readPause: std_ulogic := '0';

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset_int <= '1', '0' after 2*clockPeriod;
  reset <= reset_int;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                      -- Rx read
  read_frames <= '1',
                 '0' after  50 us,
                 '1' after 320 us;

  buildReadPauses: process
  begin
    readPause <= '0';
    for index in 1 to pauseDelayPeriods-2 loop
      wait until rising_edge(clock_int);
    end loop;
--    readPause <= '1';
    readPause <= '0';
    for index in 1 to 2 loop
      wait until rising_edge(clock_int);
    end loop;
  end process buildReadPauses;

  rx_fifoRead <= not rx_fifoEmpty when (readPause = '0') and (read_frames = '1')
    else '0';

  --TODO: end simulation if long time (~1sec) no action (rx_fifoEmpty==1) on net

END ARCHITECTURE test;
