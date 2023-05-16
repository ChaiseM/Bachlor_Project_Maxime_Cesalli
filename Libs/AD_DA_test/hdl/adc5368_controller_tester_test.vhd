library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF adc5368_controller_tester IS

  constant clockFrequency : real := 66.0E6;
  constant clockPeriod     : time := 1.0/clockFrequency * 1 sec;
  signal clock_int         : std_ulogic := '1';

  constant sampleFrequency : real := 48.0E3;
  constant signal1Frequency : real := sampleFrequency / 2.0;
  constant signal2Frequency : real := signal1Frequency / 2.0;
  constant signal3Frequency : real := signal2Frequency / 2.0;
  constant signal4Frequency : real := signal3Frequency / 2.0;
  constant signal5Frequency : real := signal4Frequency / 2.0;
  constant signal6Frequency : real := signal5Frequency / 2.0;
  constant signal7Frequency : real := signal6Frequency / 2.0;
  constant signal8Frequency : real := signal7Frequency / 2.0;
  signal tReal: real := 0.0;
  signal signal1Real: real := 0.0;
  signal signal2Real: real := 0.0;
  signal signal3Real: real := 0.0;
  signal signal4Real: real := 0.0;
  signal signal5Real: real := 0.0;
  signal signal6Real: real := 0.0;
  signal signal7Real: real := 0.0;
  signal signal8Real: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clock
  reset <= '1', '0' after 3*clockPeriod;
  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  init <= '0';
  testMode <= '0';

  ------------------------------------------------------------------------------
                                                                 -- DDS control
  -- DDS:
  --    fout = fck * step / 2^nbits
  --    step = 2^nbits * fout / fck
  -- ADC:
  --    f_sclk = f_mclk / ( (clockDividerMaxValue+1) / 2 )
  --    f_lr = f_sclk / (sclkDividerMaxValue+1)

--  mclkStep <= to_unsigned(integer(
--                            2.0**mclkStep'length
--                            * sampleFrequency / clockFrequency
--                            * real(sclkDividerMaxValue+1)
--                            * real(clockDividerMaxValue+1) / 2.0
--                         ), mclkStep'length);


  ------------------------------------------------------------------------------
                                                                 -- time signals
  process(clock_int)
  begin
    if rising_edge(clock_int) then
      tReal <= tReal + 1.0/clockFrequency;
    end if;
  end process;

  signal1Real <= sin(2.0*math_pi*signal1Frequency*tReal);
  signal2Real <= sin(2.0*math_pi*signal2Frequency*tReal);
  signal3Real <= sin(2.0*math_pi*signal3Frequency*tReal);
  signal4Real <= sin(2.0*math_pi*signal4Frequency*tReal);
  signal5Real <= sin(2.0*math_pi*signal5Frequency*tReal);
  signal6Real <= sin(2.0*math_pi*signal6Frequency*tReal);
  signal7Real <= sin(2.0*math_pi*signal7Frequency*tReal);
  signal8Real <= sin(2.0*math_pi*signal8Frequency*tReal);

  ain1 <= integer(signal1Real * real(2**(signalBitNb-1)-1));
  ain2 <= integer(signal2Real * real(2**(signalBitNb-1)-1));
  ain3 <= integer(signal3Real * real(2**(signalBitNb-1)-1));
  ain4 <= integer(signal4Real * real(2**(signalBitNb-1)-1));
  ain5 <= integer(signal5Real * real(2**(signalBitNb-1)-1));
  ain6 <= integer(signal6Real * real(2**(signalBitNb-1)-1));
  ain7 <= integer(signal7Real * real(2**(signalBitNb-1)-1));
  ain8 <= integer(signal8Real * real(2**(signalBitNb-1)-1));

END ARCHITECTURE test;
