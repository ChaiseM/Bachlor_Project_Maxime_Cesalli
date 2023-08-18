library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF adc7886_tester IS
                                                                 -- serial clock
  constant samplingPeriod : time := 1.0/samplingRate * 1 sec;
  constant serialClockFrequency : real := 20.0 * samplingRate;
  constant serialClockPeriod : time := 1.0/serialClockFrequency * 1 sec;
  signal serialClock : std_ulogic := '1';
                                                                -- test sequence
  signal chipSelect : std_ulogic;
                                                                  -- acquisition
  signal dataShiftRegister: unsigned(signalBitNb+4-1 downto 0);
  signal sample : natural;
                                                                 -- time signals
  constant signalAmplitude : real := 2.0**signalBitNb - 1.0;
  constant signalFrequency : real := samplingRate / 10.0;
  signal tReal, signalReal: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                                 -- serial clock
  serialClock <= not serialClock after serialClockPeriod/2;
  SCLK <= serialClock;

  ------------------------------------------------------------------------------
                                                                      -- control
  testSequence : process
  begin
    chipSelect <= '0';
    wait for 2*samplingPeriod;
                                                              -- normal sampling
    for index in 1 to 20 loop
                                                         -- wait 4 SCLK pulses
      for index in 1 to 4 loop
        wait until rising_edge(serialClock);
      end loop;
                                               -- assert CS for 16 SCLK pulses
      chipSelect <= '1';
      for index in 1 to 16 loop
        wait until rising_edge(serialClock);
      end loop;
      chipSelect <= '0';

    end loop;
    wait for 2*samplingPeriod;
                                                             -- go to power down
    chipSelect <= '1';
    for index in 1 to 8 loop
      wait until rising_edge(serialClock);
    end loop;
    chipSelect <= '0';
    wait for 2*samplingPeriod;
                                                             -- leave power down
    chipSelect <= '1';
    for index in 1 to 12 loop
      wait until rising_edge(serialClock);
    end loop;
    chipSelect <= '0';
    wait for 2*samplingPeriod;
                                                                 -- sample again
    chipSelect <= '1';
    for index in 1 to 16 loop
      wait until rising_edge(serialClock);
    end loop;
    chipSelect <= '0';
                                                                 -- end of tests
    wait;
  end process testSequence;

  CS_n <= not chipSelect;

  ------------------------------------------------------------------------------
                                                                  -- acquisition
  acquireSample: process(CS_n, SCLK)
    variable bitCounter : natural;
  begin
    if CS_n = '1' then
      bitCounter := 0;
      dataShiftRegister <= (others => '0');
    elsif rising_edge(SCLK) then
      bitCounter := bitCounter + 1;
      if bitCounter < dataShiftRegister'length then
        dataShiftRegister <= shift_left(dataShiftRegister, 1);
        dataShiftRegister(0) <= SDO;
      end if;
      if bitCounter = dataShiftRegister'length then
        sample <= to_integer(dataShiftRegister);
      end if;
    end if;
  end process acquireSample;

  --============================================================================
                                                                 -- time signals
  process(serialClock)
  begin
    if rising_edge(serialClock) then
      tReal <= tReal + 1.0/serialClockFrequency;
    end if;
  end process;

  signalReal <= 0.5 * signalAmplitude * (
    1.0 + sin(2.0*math_pi*signalFrequency*tReal)
  );

  VIN <= integer(signalReal);

END ARCHITECTURE test;
