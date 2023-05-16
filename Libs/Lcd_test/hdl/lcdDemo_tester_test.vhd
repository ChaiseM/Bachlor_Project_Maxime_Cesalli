ARCHITECTURE test OF lcdDemo_tester IS

  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';

  constant testInterval:time := 0.1 ms;
  constant initSequenceLength:time := 20 us;
  constant helloSequenceLength:time := 1 ms;

  constant rs232Frequency: real := real(baudRate);
  constant rs232Period: time := (1.0/rs232Frequency) * 1 sec;
  constant rs232WriteInterval: time := 10*rs232Period;
  
  signal rs232OutString : string(1 to 32);
  signal rs232SendOutString: std_uLogic;
  signal rs232SendOutDone: std_uLogic;
  signal rs232OutByte: character;
  signal rs232SendOutByte: std_uLogic;
  
BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
  begin
    rs232SendOutString <= '0';
    buttons <= (others => '0');
    wait for initSequenceLength + helloSequenceLength;
                                                  -- send bytes from serial port
    rs232OutString <= "a                               ";
    rs232SendOutString <= '1', '0' after 1 ns;
    wait until rs232SendOutDone = '1';
    wait for rs232WriteInterval;

    rs232OutString <= "hello world                     ";
    rs232SendOutString <= '1', '0' after 1 ns;
    wait until rs232SendOutDone = '1';
    wait for rs232WriteInterval;
    wait for testInterval;
                                                           -- send hello message
    wait until rising_edge(clock_int);
    for index in buttons'range loop
      buttons(index) <= '1';
      wait until rising_edge(clock_int);
      buttons(index) <= '0';
      wait until rising_edge(clock_int);
    end loop;
    wait for helloSequenceLength;
    wait for testInterval;
                                                            -- end of simulation
    assert false
      report "End of simulation"
      severity failure;
    wait;
  end process;

--============================================================================
                                                                 -- RS232 send
  rsSendSerialString: process
    constant rs232BytePeriod : time := 15*rs232Period;
    variable commandRight: natural;
  begin
    rs232SendOutByte <= '0';
    rs232SendOutDone <= '0';

    wait until rising_edge(rs232SendOutString);

    commandRight := rs232OutString'right;
    while rs232OutString(commandRight) = ' ' loop
      commandRight := commandRight-1;
    end loop;

    for index in rs232OutString'left to commandRight loop
      rs232OutByte <= rs232OutString(index);
      rs232SendOutByte <= '1', '0' after 1 ns;
      wait for rs232BytePeriod;
    end loop;

    rs232OutByte <= cr;
    rs232SendOutByte <= '1', '0' after 1 ns;
    wait for rs232BytePeriod;

    rs232SendOutDone <= '1';
    wait for 1 ns;
  end process rsSendSerialString;
                                                                  -- send byte
  rsSendSerialByte: process
    variable txData: unsigned(7 downto 0);
  begin
    RxD <= '1';

    wait until rising_edge(rs232SendOutByte);
    txData := to_unsigned(character'pos(rs232OutByte), txData'length);

    RxD <= '0';
    wait for rs232Period;

    for index in txData'reverse_range loop
      RxD <= txData(index);
      wait for rs232Period;
    end loop;

  end process rsSendSerialByte;

END ARCHITECTURE test;
