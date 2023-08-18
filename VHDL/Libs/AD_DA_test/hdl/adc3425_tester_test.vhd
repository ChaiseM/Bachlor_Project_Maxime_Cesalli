library ieee;
  use ieee.math_real.all;
library Common;
  use Common.CommonLib.all;

ARCHITECTURE test OF adc3425_tester IS

  constant i2cPeriod: time := 1.0/i2cRate * 1 sec;

  constant i2cDataBitNb : positive := 8;
  constant chipAddress: unsigned(i2cDataBitNb-1-1 downto 0) := "1101" & "000";

  signal i2cWriteData: unsigned(i2cDataBitNb-1 downto 0);
  signal i2cWrite: std_ulogic;
  signal i2cRead: std_ulogic;
  signal i2cReadData: signed(i2cDataBitNb-1 downto 0);
  signal i2cReady: std_ulogic;

  signal i2cSignalSample: signed(2*i2cDataBitNb-1 downto 0);

  signal sampleFrequency : real := 100.3E3;
  signal signalFrequency : real := sampleFrequency / 9.0;
  signal tEn: std_ulogic := '0';
  signal tReal: real := 0.0;
  signal signalAmplitude : real := 2.0**(signalBitNb-1) - 1.0;
  signal signalReal: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                                -- test sequence
  testSequence: process
  begin
    i2cWrite <= '0';
    i2cRead <= '0';
    wait for 5*i2cPeriod;
                                                       -- write control register
    i2cWriteData <= '1' & "00" & '1' & "10" & "00";
    wait for 0 ns;
    i2cWrite <= '1', '0' after 1 ns;
    wait until rising_edge(i2cReady);
                                                               -- write ADC data
    wait for 10*i2cPeriod;
    i2cRead <= '1', '0' after 1 ns;
    wait until rising_edge(i2cReady);
                                                            -- end of simulation
    wait;
  end process testSequence;

  ------------------------------------------------------------------------------
                                                                          -- I2C
  i2cDriver: process
    variable started: boolean := false;
    variable read_write: boolean;
    variable address: unsigned(chipAddress'high+2 downto 0);
    variable dataOut: unsigned(i2cWriteData'high+1 downto 0);
    variable dataIn: signed(i2cReadData'range);
  begin
    SCL <= '1';
    SDA <= '1';
    i2cReady <= '1';
    read_write := false;
    address := chipAddress & "0H";
    wait on i2cWrite, i2cRead;
    if started then
      if rising_edge(i2cRead) then
        read_write := true;
        address(1) := 'H';
      end if;
      dataOut := i2cWriteData & 'H';
      i2cReady <= '0';
                                                                   -- send start
      SDA <= '0';
      wait for i2cPeriod/4;
      SCL <= '0';
      wait for i2cPeriod/4;
                                                                 -- send address
      for index in address'range loop
        SDA <= address(index);
        wait for i2cPeriod/4;
        SCL <= '1';
        wait for i2cPeriod/2;
        SCL <= '0';
        wait for i2cPeriod/4;
      end loop;
                                                                -- read sequence
      if read_write then
        for byteIndex in 1 to 3 loop
          dataOut := (0 => '0', others => 'H');
          if byteIndex = 3 then
            dataOut(0) := '1';
          end if;
          for bitIndex in dataOut'range loop
            SDA <= dataOut(bitIndex);
            wait for i2cPeriod/4;
            SCL <= '1';
            dataIn := shift_left(dataIn, 1);
            dataIn(0) := To_X01(sDa);
            if bitIndex = 1 then
              if byteIndex = 2 then
                i2cSignalSample <= i2cReadData & dataIn;
              end if;
              i2cReadData <= dataIn;
            end if;
            wait for i2cPeriod/2;
            SCL <= '0';
            wait for i2cPeriod/4;
          end loop;
        end loop;
                                                               -- write sequence
      else
        for index in dataOut'range loop
          SDA <= dataOut(index);
          wait for i2cPeriod/4;
          SCL <= '1';
          wait for i2cPeriod/2;
          SCL <= '0';
          wait for i2cPeriod/4;
        end loop;
      end if;
                                                                    -- send stop
      SDA <= '0';
      wait for i2cPeriod/4;
      SCL <= '1';
      wait for i2cPeriod/4;
    end if;
    started := true;

  end process i2cDriver;

  --============================================================================
                                                                -- analog signal
  tEn <= not tEn after 1.0/(sampleFrequency*2.0) * 1 sec;

  process(tEn)
  begin
    if rising_edge(tEn) then
      tReal <= tReal + 1.0/sampleFrequency;
    end if;
  end process;

  signalReal <= signalAmplitude * sin(2.0*math_pi*signalFrequency*tReal);
  VINp <= integer(signalReal) when signalReal > 0.0
    else 0;
  VINm <= -integer(signalReal) when signalReal < 0.0
    else 0;

END ARCHITECTURE test;
