ARCHITECTURE test OF dac5543_tester IS

  constant Tcss: time :=  0 ns;
  constant Tds: time  :=  5 ns;
  constant Tch: time  := 10 ns;
  constant Tcl: time  := 10 ns;
  constant Tdh: time  := 10 ns;
  constant Tcsh: time := 10 ns;

  constant samplingPeriod: time := (1.0/samplingRate) * 1 sec;
  signal amplitude_int: natural;
  signal sendNewValue: std_ulogic;

  signal CS: std_ulogic;
  signal shiftRegister: unsigned(dacBitNb-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
  begin
    amplitude_int <= 0;
    sendNewValue <= '0';
    wait for samplingPeriod;
                                                             -- prepare values
    for index in 1 to 20 loop
      amplitude_int <= index;
      sendNewValue <= '1', '0' after 1 ns;
      wait for samplingPeriod;
    end loop;
                                                          -- end of simulation
    wait;
  end process;

  ------------------------------------------------------------------------------
                                                                   -- serializer
  process
  begin
    CS <= '0';
    CLK <= '0';
    SDI <= '-';

    wait until rising_edge(sendNewValue);
    CS <= '1';
    shiftRegister <= to_unsigned(amplitude_int, shiftRegister'length);
    wait for Tcss;
    for index in 1 to dacBitNb loop
      SDI <= shiftRegister(shiftRegister'high);
      wait for Tds;
      CLK <= '1';
      wait for Tch;
      CLK <= '0';
      wait for Tdh - Tch;
      shiftRegister(shiftRegister'high downto 1) <= shiftRegister(shiftRegister'high-1 downto 0);
      wait for Tcl - Tds;
    end loop;
    wait for Tcsh - Tdh;
    CS <= '0';
    SDI <= '0';

  end process;

  CS_n <= not CS;

END ARCHITECTURE test;
