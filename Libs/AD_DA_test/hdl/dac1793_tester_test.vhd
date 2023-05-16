library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF dac1793_tester IS

  constant rstPulseDuration: time := 20 ns;

  signal fmt_int : std_ulogic_vector(FMT'range);

  signal sampleFrequency : real;
  signal samplePeriod: time := 1.0/48.0E3 * 1 sec;
  signal sampleEn : std_ulogic := '1';
  signal signalLeftFrequency : real := 48.0E3;
  signal signalRightFrequency : real := 48.0E3;
  signal signalLeftAmplitude : real := 2.0**(signalBitNb-1) - 1.0;
  signal signalRightAmplitude : real := 2.0**(signalBitNb-2);
  signal tReal: real := 0.0;
  signal signalLeftReal: real;
  signal signalRightReal: real;
  signal signalLeftSigned: signed(signalBitNb-1 downto 0);
  signal signalRightSigned: signed(signalBitNb-1 downto 0);

  signal sckFrequency: real;
  signal sckPeriod: time := 1.0/73.728E6 * 1 sec;
  signal sck_int: std_ulogic := '1';
  signal sckToBckRatio: positive;
  constant channelBitNb: positive := 32;
  constant bckToLrckRatio: positive := 2*channelBitNb;
  signal bck_int, lrck_int: std_ulogic := '0';
  signal bckCounter, lrckCounter: natural := 0;
  signal dacBitNb: integer := signalBitNb;
  signal bitCounter: integer := 0;
  signal bitCounterValid, leftChannelSelected: boolean;
  signal bckDelayed: std_ulogic;

BEGIN
  --============================================================================
                                                                -- test sequence
  testSequence: process
  begin
    ----------------------------------------------------------------------------
                                                  -- 192 kHz, 192 fs, 24-bit I2S
    DEMP <= "00";
    fmt_int <= "101";
    MUTE <= '0';
    RST_n <= not '0', not '1' after rstPulseDuration;
    sckFrequency <= 36.864E6;
    sckToBckRatio <= 3;

    wait;
  end process testSequence;

  FMT <= fmt_int;

  --============================================================================
                                                                 -- time signals
  sampleFrequency <= sckFrequency / real(sckToBckRatio * bckToLrckRatio);
  samplePeriod <= 1.0/sampleFrequency * 1 sec;
  sampleEn <= '0' after sckPeriod when sampleEn = '1'
    else '1' after samplePeriod-sckPeriod;

  signalLeftFrequency <= sampleFrequency / 10.0;
  signalRightFrequency <= sampleFrequency / 10.0;

  process(sampleEn)
  begin
    if rising_edge(sampleEn) then
      tReal <= tReal + 1.0/ sampleFrequency;
    end if;
  end process;

  signalLeftReal <= signalLeftAmplitude * sin(2.0*math_pi*signalLeftFrequency*tReal);
--  signalRightReal <= signalRightAmplitude * sin(2.0*math_pi*signalRightFrequency*tReal);
  signalRightReal <= signalRightAmplitude;

  signalLeftSigned <= to_signed(integer(signalLeftReal), signalLeftSigned'length);
  signalRightSigned <= to_signed(integer(signalRightReal), signalRightSigned'length);

  --============================================================================
                                                                   -- main clock
  sckPeriod <= 1.0/sckFrequency * 1 sec;
  sck_int <= not sck_int after sckPeriod/2;
  SCK <= sck_int;
                                                               -- derived clocks
  process(sck_int)
  begin
    if rising_edge(sck_int) or falling_edge(sck_int) then
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

  BCK <= bck_int;
  LRCK <= lrck_int;

  --============================================================================
                                                                  -- serial data
  dacBitNb <= 16 when fmt_int(1 downto 0) = "00"
    else 20 when fmt_int = "001"
    else 24;
                                                                  -- bit counter
  process(lrck_int, bck_int)
  begin
    if rising_edge(lrck_int) or falling_edge(lrck_int) then
      if fmt_int(2) = '1' then -- I2S
        bitCounter <= dacBitNb;
      elsif fmt_int = "011" then -- left-justified
        bitCounter <= dacBitNb-1;
      else -- right-justified
        bitCounter <= channelBitNb-1;
      end if;
    elsif falling_edge(bck_int) then
      bitCounter <= bitCounter - 1;
    end if;
  end process;
                                                         -- bit write conditions
  bitCounterValid <= true when (bitCounter < dacBitNb) and (bitCounter >= 0)
    else false;
  leftChannelSelected <= true when (lrck_int = '0') and (fmt_int(2) = '1') -- I2S
    else true when (lrck_int = '1') and (fmt_int(2) = '0')
    else false;
                                                                    -- bit write
  bckDelayed <= bck_int after 1 ns;
  process(bckDelayed)
  begin
    if falling_edge(bckDelayed) then
      if bitCounterValid then
        if leftChannelSelected then
          data <= signalLeftSigned(bitCounter);
        else 
          data <= signalRightSigned(bitCounter);
        end if;
      else
        data <= '-';
      end if;
    end if;
  end process;

END ARCHITECTURE test;
