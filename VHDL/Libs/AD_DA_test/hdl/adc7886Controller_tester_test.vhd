library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF adc7886Controller_tester IS

                                                              -- reset and clock
  constant clockPeriod : time := 1.0/clockFrequency * 1 sec;
  signal clock_int     : std_ulogic := '1';
                                                                    -- SPI clock
  signal sclkEn_int : std_ulogic;
                                                                -- analog signal
  constant samplingPeriod : time := 1.0/samplingFrequency * 1 sec;
  constant signalFrequency : real := samplingFrequency / 20.0;
  constant signalAmplitude : real := 2.0**(adcBitNb-1) - 1.0;
  constant signalOversampling : positive := 10;
  signal tReal, tReal1: real := 0.0;
  signal signalReal: real := 0.0;

BEGIN
                                                              -- reset and clock
  reset <= '1', '0' after 3*clockPeriod;
  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;
                                                                    -- SPI clock
  buildSpiClockEnable: process
  begin
    sclkEn_int <= '0';
    for index in 1 to integer(clockFrequency/spiFrequency + 0.5) loop
      wait until rising_edge(clock_int);
    end loop;
    sclkEn_int <= '1';
    wait until rising_edge(clock_int);
  end process buildSpiClockEnable;

  sclkEn <= sclkEn_int;
                                                                     -- sampling
  buildSampleEnable: process
  begin
    startConv <= '0';
    for index in 1 to integer(clockFrequency/samplingFrequency + 0.5) loop
      wait until rising_edge(clock_int);
    end loop;
    startConv <= '1';
    wait until rising_edge(clock_int);
  end process buildSampleEnable;

  ------------------------------------------------------------------------------
                                                                -- analog signal
  tReal1 <= tReal1 + 1.0/samplingFrequency after samplingPeriod;
  tReal <= tReal + 1.0/(real(signalOversampling)*samplingFrequency)
    after samplingPeriod/signalOversampling;

  signalReal <= 0.5*(sin(2.0*math_pi*signalFrequency*tReal) + 1.0);
  VIN <= integer(signalAmplitude*signalReal);

END ARCHITECTURE test;
