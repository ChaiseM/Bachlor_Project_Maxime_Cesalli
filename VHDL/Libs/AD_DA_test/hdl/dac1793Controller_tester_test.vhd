library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF dac1793Controller_tester IS

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock : std_ulogic := '1';

  constant samplingPeriod: time := 1.0/samplingFrequency * 1 sec;
  signal sampleEn : std_ulogic := '1';
  signal signalLeftFrequency : real := samplingFrequency/10.0;
  signal signalRightFrequency : real := samplingFrequency/10.0;
  signal signalLeftAmplitude : real := 2.0**(dacBitNb-1) - 1.0;
  signal signalRightAmplitude : real := 2.0**(dacBitNb-2);
  signal tReal: real := 0.0;
  signal signalLeftReal: real;
  signal signalRightReal: real;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                 -- time signals
  sampleEn <= '0' after clockPeriod when sampleEn = '1'
    else '1' after samplingPeriod-clockPeriod;

  process(sampleEn)
  begin
    if rising_edge(sampleEn) then
      tReal <= tReal + 1.0/ samplingFrequency;
    end if;
  end process;

  signalLeftReal <= signalLeftAmplitude * sin(2.0*math_pi*signalLeftFrequency*tReal);
--  signalRightReal <= signalRightAmplitude * sin(2.0*math_pi*signalRightFrequency*tReal);
  signalRightReal <= signalRightAmplitude;

  amplitudeLeft <= to_signed(integer(signalLeftReal), amplitudeLeft'length);
  amplitudeRight <= to_signed(integer(signalRightReal), amplitudeRight'length);

END ARCHITECTURE test;

