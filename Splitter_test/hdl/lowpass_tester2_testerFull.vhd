--
-- VHDL Architecture Splitter_test.lowpass_tester2.testerFull
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 11:43:59 26.05.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
library ieee;
  use ieee.math_real.all;

ARCHITECTURE testerFull OF lowpass_tester2 IS
 constant CLOCK_PERIOD: time := (1.0/CLOCK_FREQUENCY) * 1 sec;
  signal sClock: std_uLogic := '1';
                                                                     -- sampling
  constant SAMPLING_PERIOD: time := (1.0/SAMPLING_FREQUENCY) * 1 sec;
  signal sEn: std_uLogic := '1';
                                                              -- frequency sweep
  constant minFrequencyLog: real := 3.0;
  constant maxFrequencyLog: real := 6.0;
  constant frequencyStepLog: real := 1.0/10.0;
  constant frequencyStepPeriod: time := 1.0 * (1.0/(10.0**minFrequencyLog)) * 3 sec;
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
    wait for SAMPLING_PERIOD/2;
    sEn <= '1';
    wait for SAMPLING_PERIOD/2;         
  end process;

  process(sClock)
  begin
    if rising_edge(sClock) then
        CLKI2s <= sEn;
    end if;
  end process;

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
      if en = '1' then
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
  
    sig0 <= '0';
    sig1 <= '0';
    sig2 <= '0';
    sig3 <= '0';
    sig4 <= '0';
    sig5 <= '0';
    sig6 <= '0';
    sig7 <= '0';
    sig8 <= '0';
    sig9 <= '0';
    sig10 <= '0';
    sig11 <= '0';

END ARCHITECTURE testerFull;
