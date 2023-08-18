library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF adc128S102Controller_tester IS
                                                              -- reset and clock
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal sClock : std_ulogic := '1';
                                                                     -- sampling
  constant samplingPeriod: time := (1.0/samplingFrequency) * 1 sec;
  signal sEn : std_ulogic := '1';
                                                                -- input signals
  constant in0Frequency : real := 0.0 * samplingFrequency/2.0;
  constant in1Frequency : real := 0.1 * samplingFrequency/2.0;
  constant in2Frequency : real := 0.2 * samplingFrequency/2.0;
  constant in3Frequency : real := 0.3 * samplingFrequency/2.0;
  constant in4Frequency : real := 0.4 * samplingFrequency/2.0;
  constant in5Frequency : real := 0.5 * samplingFrequency/2.0;
  constant in6Frequency : real := 0.6 * samplingFrequency/2.0;
  constant in7Frequency : real := 0.7 * samplingFrequency/2.0;
  constant signalAmplitude : real := 2.0**(adcBitNb-1) - 1.0;
  signal tReal: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  sClock <= not sClock after clockPeriod/2;
  clock <= transport sClock after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                     -- sampling
  buildEnable: process
  begin
    sEn <= '0';
    wait for samplingPeriod - 2*clockPeriod;
    wait until rising_edge(sClock);
    sEn <= '1';
    wait until rising_edge(sClock);
  end process buildEnable;

  sampleEn <= sEn;

  ------------------------------------------------------------------------------
                                                                -- input signals
  process(sClock)
  begin
    if rising_edge(sClock) then
      tReal <= tReal + 1.0/clockFrequency;
    end if;
  end process;

  IN0 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in0Frequency*tReal))),
    IN0'length
  );
  IN1 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in1Frequency*tReal))),
    IN1'length
  );
  IN2 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in2Frequency*tReal))),
    IN2'length
  );
  IN3 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in3Frequency*tReal))),
    IN3'length
  );
  IN4 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in4Frequency*tReal))),
    IN4'length
  );
  IN5 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in5Frequency*tReal))),
    IN5'length
  );
  IN6 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in6Frequency*tReal))),
    IN6'length
  );
  IN7 <= to_unsigned(
    integer(signalAmplitude/2.0 * (1.0 + sin(2.0*math_pi*in7Frequency*tReal))),
    IN7'length
  );

END ARCHITECTURE test;
