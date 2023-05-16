library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF dac124S085_tester IS
                                                                 -- serial clock
  constant samplingPeriod : time := 1.0/samplingRate * 1 sec;
  constant serialClockFrequency : real := 20.0 * samplingRate;
  constant serialClockPeriod : time := 1.0/serialClockFrequency * 1 sec;
  signal serialClock : std_ulogic := '1';
                                                                  -- DAC control
  constant opWriteReg          : natural := 0;
  constant opWriteAndUpdate    : natural := 1;
  constant opWriteAllAndUpdate : natural := 2;
  constant opPowerDown         : natural := 3;
  signal sendSample : std_ulogic;
  signal dacId, opId : natural;
  signal sync : std_ulogic;
  signal shiftRegister : unsigned(15 downto 0) := (others => '0');
                                                                 -- time signals
  constant signalAmplitude : real := 2.0**dacBitNb - 1.0;
  constant signalFrequency : real := samplingRate / 10.0;
  signal tReal: real := 0.0;
  signal signalInteger: natural := 0;

BEGIN
  ------------------------------------------------------------------------------
                                                                 -- serial clock
  serialClock <= not serialClock after serialClockPeriod/2;
  SCLK <= serialClock;

  ------------------------------------------------------------------------------
                                                                  -- DAC control
  testSequence : process
  begin
    sendSample <= '0';
    wait for 5*samplingPeriod;
                                                                 -- send samples
    opId <= opWriteAndUpdate;
    for dacIndex in 1 to 4 loop
      dacId <= dacIndex-1;
      wait for 0 ns;
      for sampleIndex in 1 to 20 loop
        sendSample <= '1', '0' after 1 ns;
        wait for samplingPeriod;
      end loop;
      wait for 5*samplingPeriod;
    end loop;
                                                                 -- end of tests
    wait;
  end process testSequence;

  --============================================================================
                                                                 -- time signals
  process(serialClock)
  begin
    if rising_edge(serialClock) then
      tReal <= tReal + 1.0/serialClockFrequency;
    end if;
  end process;

  signalInteger <= integer(0.5 * signalAmplitude * (
    1.0 + sin(2.0*math_pi*signalFrequency*tReal)
  ) + 0.5);

  --============================================================================
                                                                  -- serial send
  sendCommand: process
  begin
    sync <= '0';
    wait until rising_edge(sendSample);
    shiftRegister <= to_unsigned(signalInteger, shiftRegister'length);
    shiftRegister(shiftRegister'high downto shiftRegister'high-1)
      <= to_unsigned(dacId, 2);
    shiftRegister(shiftRegister'high-2 downto shiftRegister'high-3)
      <= to_unsigned(opId, 2);
    --shiftRegister <= to_unsigned(16#C003#, shiftRegister'length);
    wait until rising_edge(serialClock);
    wait for 1 ns;
    sync <= '1';
    for index in shiftRegister'range loop
      wait until rising_edge(serialClock);
      shiftRegister <= shift_left(shiftRegister, 1);
    end loop;
    wait for 1 ns;
  end process sendCommand;

  SYNC_n <= not sync;
  DIN <= shiftRegister(shiftRegister'high);

END ARCHITECTURE test;
