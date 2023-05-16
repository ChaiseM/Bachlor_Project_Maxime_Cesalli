library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF adc5368_tester IS

  constant clockFrequency : real := 66.0E6;
  constant clockPeriod    : time := 1.0/clockFrequency * 1 sec;
  signal clock_int        : std_ulogic := '1';
  signal reset_int        : std_ulogic := '1';

  constant sampleFrequency : real := 48.0E3;
  constant mclkFrequency   : real := 64.0 * sampleFrequency;
  constant mclkPeriod      : time := 1.0/mclkFrequency * 1 sec;
  signal mclk_int          : std_ulogic := '0';

  constant signalBitNb : positive := 16;
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
  reset_int <= '1', '0' after 4*clockPeriod;
  rst_n <= not reset_int;

  clock_int <= not clock_int after clockPeriod/2;
  --clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                    -- ADC setup
  -- Prescaler divide by 1
  clkmode       <= '0';
  mdiv          <= '0';
  -- Quadruple-speed master mode
  m1_scl_cclk   <= '1';
  m0_sda_cdout  <= '0';
  -- serial audio format: I2S
  dif1_ad1_cdin <= '0';
  dif0_ad0_cs_n <= '1';

  ------------------------------------------------------------------------------
                                                                   -- ADC clocks
  mclk_int <= not mclk_int after mclkPeriod/2;
  mclk <= mclk_int;
  sclk <= 'Z';
  lrck_fs <= 'Z';

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
