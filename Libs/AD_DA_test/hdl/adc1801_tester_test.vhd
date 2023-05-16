library ieee;
  use ieee.math_real.all;

 ARCHITECTURE test OF adc1801_tester IS

--  constant rstPulseDuration: time := 40 ns;
--signal clockFrequency: real;
--signal clockPeriod: time := 30 ns;
  constant clockFrequency: real := 18432000.0;
  signal clockPeriod: time := 54 ns;
  signal sClock : std_ulogic := '1';
  constant sampleFrequency : real := 48.0E3; 
--signal sckToBCKRatio: positive := 6; --FMT=0 FMT=1 	--> I2S and left justified
  signal sckToBCKRatio: positive := 8/2; --FMT=0 FMT=1 	--> I2S and left justified
--signal sckToBCKRatio: positive := 12;--FMT=0 			-->left justified only

  constant channelBitNb: positive := 16;
--constant BCKToLRCKRatio: positive := 32/2; --left justified only, sckToBCKRatio=12
  constant BCKToLRCKRatio: positive := 48/2; --I2S and left justified, sckToBCKRatio=8
--constant BCKToLRCKRatio: positive := 64/2; --I2S and left justified, , sckToBCKRatio=6
  
  signal intBCK: std_ulogic := '0';
  signal intLRCK: std_ulogic := '0';

  signal sckiCounter, bckCounter: natural := 0;

--input simulation signals
  signal signalLeftFrequency : real := 0.9*sampleFrequency / 2.0;
  signal signalRightFrequency : real := 0.9*sampleFrequency / 4.0;
  signal signalLeftAmplitude : real := 2.0**(signalBitNb-1) - 1.0;
  signal signalRightAmplitude : real := 2.0**(signalBitNb-1) - 1.0;
  signal signalLeftReal: real := 0.0;
  signal signalRightReal: real := 0.0;

--simulation sequence declarations
  signal tReal: real := 0.0;
  constant sample_period : time := 1.0 / sampleFrequency * 1 sec;
  constant FMT_test_period : time := 5 * sample_period;

BEGIN
  ------------------------------------------------------------------------------
  VREF1 <= (others => '0');
  VREF2 <= (others => '0');
  BYPAS <= '0';
																-- main clock
  clockPeriod <= 1.0/clockFrequency * 1 sec;
  sClock <= not sClock after clockPeriod/2;
  SCKI <= sClock;
                                                               -- derived clocks
  process(sClock)
  begin
    if rising_edge(sClock) then
      if sckiCounter < sckToBCKRatio - 1 then
        sckiCounter <= sckiCounter + 1;
      else
        sckiCounter <= 0;
        if intBCK = '1' then
          if bckCounter < BCKToLRCKRatio - 1 then
            bckCounter <= bckCounter + 1;
          else
            bckCounter <= 0;
            intLRCK <= not intLRCK;
          end if;
        end if;
        intBCK <= not intBCK;
      end if;
    end if;
  end process;
  BCK <= intBCK;
  LRCK <= intLRCK;
  --============================================================================
                                                                -- test sequence
  testSequence: process
  begin
	FMT <= '0';
    wait for FMT_test_period;
	FMT <= '1';
	--wait for FMT_test_period;
	
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
  signalRightReal <= signalRightAmplitude * sin(2.0*math_pi*signalRightFrequency*tReal);

  VINL <= to_signed(integer(signalLeftReal),signalBitNb);
  VINR <= to_signed(integer(signalRightReal),signalBitNb);

END ARCHITECTURE test;
