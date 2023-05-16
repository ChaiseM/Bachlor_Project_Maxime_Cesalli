library ieee;
  use ieee.math_real.all;

ARCHITECTURE sweep OF lowpass_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

  constant enablePeriod: positive := 4;
  signal sEn: std_uLogic := '0';

  constant minFrequencyLog: real := 3.0;
  constant maxFrequencyLog: real := 5.0;
  constant frequencyStepLog: real := 1.0/5.0;
  constant frequencyStepPeriod: time := 1.0 * (1.0/(10.0**minFrequencyLog)) * 1 sec;
  signal tReal: real := 0.0;
  signal phase: real := 0.0;
  signal sineFrequency: real;
  signal outAmplitude: real := 1.0;
  signal outReal: real := 0.0;
  signal outSigned: signed(filterIn'range);

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
        tReal <= tReal + real(enablePeriod)/clockFrequency;
        phase <= phase + 2.0*math_pi*sineFrequency*real(enablePeriod)/clockFrequency;
      end if;
    end if;
  end process;

  outReal <= outAmplitude * sin(phase);

  outSigned <= to_signed(
    integer(outReal * ( 2.0**(outSigned'length-1) - 1.0 )),
    outSigned'length
  );
  filterIn <= outSigned;

END ARCHITECTURE sweep;

