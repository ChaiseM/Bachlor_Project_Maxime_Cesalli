library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF adc1804Controller_tester IS

  constant rstPulseDuration: time := 40 ns;

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock : std_ulogic := '1';

  signal sampleFrequency : real := 48.0E3;
  signal signalLeftFrequency : real := sampleFrequency / 2.0;
  signal signalRightFrequency : real := sampleFrequency / 4.0;
  signal signalLeftAmplitude : real := 2.0**(adcBitNb-1) - 1.0;
--  signal signalRightAmplitude : real := 2.0**(signalBitNb-2);
  signal signalRightAmplitude : real := 2.0**(adcBitNb-1) - 1.0;
  signal tReal: real := 0.0;
  signal signalLeftReal: real := 0.0;
  signal signalRightReal: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                 -- time signals
  process(sClock)
  begin
    if rising_edge(sClock) then
      tReal <= tReal + 1.0/clockFrequency;
    end if;
  end process;

  signalLeftReal <= signalLeftAmplitude * sin(2.0*math_pi*signalLeftFrequency*tReal);
--  signalRightReal <= signalRightAmplitude * sin(2.0*math_pi*signalRightFrequency*tReal);
  signalRightReal <= signalRightAmplitude;

  VINLp <= integer(signalLeftReal) when signalLeftReal > 0.0
    else 0;
  VINLm <= -integer(signalLeftReal) when signalLeftReal < 0.0
    else 0;
  VINRp <= integer(signalRightReal) when signalRightReal > 0.0
    else 0;
  VINRm <= -integer(signalRightReal) when signalRightReal < 0.0
    else 0;

END ARCHITECTURE test;
