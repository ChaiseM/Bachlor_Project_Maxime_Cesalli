ARCHITECTURE step OF lowpass_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

  constant enablePeriod: positive := 10;
  signal sEn: std_uLogic;

  constant stepPeriod: time := 10000 * enablePeriod * clockPeriod;
  signal filterIn_int: integer;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                -- enable signal
  process
  begin
    sEn <= '0';
    for index in 1 to (enablePeriod-1) loop
      wait until rising_edge(sClock);
    end loop;
    sEn <= '1';
    wait until rising_edge(sClock);
  end process;

  en <= sEn;

  ------------------------------------------------------------------------------
                                                                  -- time signal
  filterIn <= (others => '0'),
              (filterIn'high => '0', others => '1') after 0.1*stepPeriod,
              (filterIn'high => '1', others => '0') after 1.1*stepPeriod;

END ARCHITECTURE step;

