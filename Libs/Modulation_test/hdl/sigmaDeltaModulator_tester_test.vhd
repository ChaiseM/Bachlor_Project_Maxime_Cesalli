library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF sigmaDeltaModulator_tester IS

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock: std_uLogic := '1';

  signal tReal: real := 0.0;
  signal outAmplitude: real := 1.0;
  signal outReal: real := 0.0;
  signal outSigned: signed(parallelIn'range);

BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock and reset
  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;
  reset <= '1', '0' after 2*clockPeriod;

  ------------------------------------------------------------------------------
                                                                -- enable signal
  en <= '1';

  ------------------------------------------------------------------------------
                                                                 -- time signals
  process(sClock)
  begin
    if rising_edge(sClock) then
      tReal <= tReal + (1.0/clockFrequency);
    end if;
  end process;

  outReal <= outAmplitude * ( sin(2.0*math_pi*sineFrequency*tReal));

  outSigned <= to_signed(integer(outReal * real(2**(outSigned'length-1)-1)), outSigned'length);
  parallelIn <= outSigned;

END ARCHITECTURE test;

