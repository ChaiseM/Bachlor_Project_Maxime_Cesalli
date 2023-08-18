library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF lowpass_tester IS
                                                              -- clock and reset
  constant CLOCK_PERIOD: time := (1.0/CLOCK_FREQUENCY) * 1 sec;
  signal sClock: std_uLogic := '1';
                                                                     -- sampling
  constant SAMPLING_PERIOD: time := (1.0/SAMPLING_FREQUENCY) * 1 sec;
  signal sEn: std_uLogic := '1';
                                                              -- frequency sweep
  constant minFrequencyLog: real := 3.0;
  constant maxFrequencyLog: real := 10.0;
  constant frequencyStepLog: real := 1.0/3.0;
  constant frequencyStepPeriod: time := 1.0 * (1.0/(10.0**minFrequencyLog)) * 1 sec;
  signal sineFrequency: real;
                                                                 -- time signals
  signal tReal: real := 0.0;
  signal phase: real := 0.0;
  signal outAmplitude: real := 1.0;
  signal outReal: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after CLOCK_PERIOD/2;
  clock <= transport sClock after CLOCK_PERIOD*9/10;
  reset <= '1', '0' after 2*CLOCK_PERIOD;

  ------------------------------------------------------------------------------
                                                                     -- sampling
  process
  begin
    sEn <= '0';
    wait for SAMPLING_PERIOD - 2*CLOCK_PERIOD - 2 ns;
    wait until rising_edge(sClock);
    sEn <= '1';
    wait until rising_edge(sClock);
  end process;

  en <= sEn;

  ------------------------------------------------------------------------------
                                                              -- frequency sweep
  process
    variable sineFrequencyLog: real;
  begin
    sineFrequencyLog := minFrequencyLog;
    sineFrequency <= 10**sineFrequencyLog;
    while sineFrequencyLog <= maxFrequencyLog loop
      wait for frequencyStepPeriod;
      sineFrequencyLog := sineFrequencyLog + frequencyStepLog;
      sineFrequency <= 10**sineFrequencyLog;
    end loop;
  end process;

  ------------------------------------------------------------------------------
                                                                 -- time signals
  process(sClock)
  begin
    if rising_edge(sClock) then
      if sEn = '1' then
        tReal <= tReal + 1.0/SAMPLING_FREQUENCY;
        phase <= phase + 2.0*math_pi*sineFrequency/SAMPLING_FREQUENCY;
      end if;
    end if;
  end process;

  outReal <= outAmplitude * sin(phase);

  audioIn <= to_signed(
    integer(outReal * ( 2.0**(audioIn'length-1) - 1.0 )),
    audioIn'length
  );

END ARCHITECTURE test;
