library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF adc1804_tester IS

  constant rstPulseDuration: time := 40 ns;

  signal clockFrequency: real;
  signal clockPeriod: time := 30 ns;
  signal sClock : std_ulogic := '1';
  signal sckToBckRatio: positive;
  constant channelBitNb: positive := 32;
  constant bckToLrckRatio: positive := 2*channelBitNb;
  signal bck_int, lrck_int: std_ulogic := '0';
  signal bckCounter, lrckCounter: natural := 0;

  signal oversamplingRatioIndex: std_ulogic_vector(OSR'range);
  signal slave_master: std_ulogic;

  signal sampleFrequency : real := 48.0E3;
  signal signalLeftFrequency : real := sampleFrequency / 2.0;
  signal signalRightFrequency : real := sampleFrequency / 4.0;
  signal signalLeftAmplitude : real := 2.0**(signalBitNb-1) - 1.0;
--  signal signalRightAmplitude : real := 2.0**(signalBitNb-2);
  signal signalRightAmplitude : real := 2.0**(signalBitNb-1) - 1.0;
  signal tReal: real := 0.0;
  signal signalLeftReal: real := 0.0;
  signal signalRightReal: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                                   -- main clock
  clockPeriod <= 1.0/clockFrequency * 1 sec;
  sClock <= not sClock after clockPeriod/2;
  SCKI <= sClock;
                                                               -- derived clocks
  process(sClock)
  begin
    if rising_edge(sClock) or falling_edge(sClock) then
      if bckCounter < sckToBckRatio-1 then
        bckCounter <= bckCounter + 1;
      else
        bckCounter <= 0;
        if bck_int = '1' then
          if lrckCounter < bckToLrckRatio/2-1 then
            lrckCounter <= lrckCounter + 1;
          else
            lrckCounter <= 0;
            lrck_int <= not lrck_int;
          end if;
        end if;
        bck_int <= not bck_int;
      end if;
    end if;
  end process;

  driveClocks: process(slave_master, bck_int, lrck_int)
  begin
    if slave_master = '1' then
      BCK_DSDL <= bck_int;
      LRCK_DSDBCK <= lrck_int;
    else
      BCK_DSDL <= 'Z';
      LRCK_DSDBCK <= 'Z';
    end if;
  end process driveClocks;

  S_M <= slave_master;

  ------------------------------------------------------------------------------
                                                                   -- power down
  updateControls: process
  begin
    RST_n <= '1';
    wait on oversamplingRatioIndex;
    RST_n <= '0';
    wait for rstPulseDuration;
  end process updateControls;

  OSR <= oversamplingRatioIndex;

  --============================================================================
                                                                -- test sequence
  testSequence: process
  begin
--    FMT <= "00";  -- left-justified
    FMT <= "01";  -- I2S
--    FMT <= "10";  -- right-justified
    clockFrequency <= 24.576E6;
    slave_master <= '0';
    oversamplingRatioIndex <= (others => '0');
    BYPAS <= '1';

    ----------------------------------------------------------------------------
                                                         -- quad rate slave mode
    slave_master <= '1';
    oversamplingRatioIndex <= "010";

    ----------------------------------------------------------------------------
                                                        -- quad rate master mode
    slave_master <= '0';
    sampleFrequency <= 192.0E3; wait for 0 ns;
    oversamplingRatioIndex <= "110";
    clockFrequency <= 192.0 * sampleFrequency;

    wait;
  end process testSequence;

  --============================================================================
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
