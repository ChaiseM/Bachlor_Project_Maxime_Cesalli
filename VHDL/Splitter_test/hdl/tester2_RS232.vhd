--
-- VHDL Architecture Splitter_test.tester2.RS232
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 16:01:15 03.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
LIBRARY Common_test;
  USE Common_test.testUtils.all;
  
ARCHITECTURE RS232 OF tester2 IS
                                                                         -- UART
  constant uartPeriod: time := (1.0/uartBaudRate) * 1 sec;
  constant uartWriteInterval: time := 20 us;
  signal uartInString : string(1 to 32);
  signal uartSendInString: std_uLogic;
  signal uartSendInDone: std_uLogic;
  signal uartInByte: character;
  signal uartSendInByte: std_uLogic;

BEGIN
                                                         
 

  ------------------------------------------------------------------------------
                                                                -- test sequence
  process
  begin
    uartSendInString <= '0';
    wait for 1*uartPeriod;
   --characters with max. 2 Morse symbols
    print("Sending characters with max. 2 symbols");
    uartInString <= pad("new0006#x!DEADBEEF!x!BAAAAAAD!", uartInString'length);
    uartSendInString <= '1', '0' after 1 ns;
    wait until uartSendInDone = '1';
    wait for uartWriteInterval;
                                              --characters starting with a dot
    print("Sending characters starting with a dot");
    uartInString <= pad("x!12345678!x!89ABCDEF!", uartInString'length);
    uartSendInString <= '1', '0' after 1 ns;
    wait until uartSendInDone = '1';
    wait for uartWriteInterval;
                                              --characters starting with a dash
    print("Sending characters starting with a dash");
    uartInString <= pad("x!AAAAAAAA!x!BAAAAAAD!x!10101010!", uartInString'length);
    uartSendInString <= '1', '0' after 1 ns;
    wait until uartSendInDone = '1';
    wait for uartWriteInterval;
    wait for 30 ms;
    
    print("Sending characters starting with a dash");
    uartInString <= pad("G0009T", uartInString'length);
    uartSendInString <= '1', '0' after 1 ns;
    wait until uartSendInDone = '1';
    wait for uartWriteInterval;
     wait for 10000000 ms;
                                                            
  
  end process;
  
  --============================================================================
                                                                   -- uart send
  rsSendSerialString: process
    constant uartBytePeriod : time := 15*uartPeriod;
    variable commandRight: natural;
  begin

    uartSendInByte <= '0';
    uartSendInDone <= '0';

    wait until rising_edge(uartSendInString);

    commandRight := uartInString'right;
    while uartInString(commandRight) = ' ' loop
      commandRight := commandRight-1;
    end loop;

    for index in uartInString'left to commandRight loop
      uartInByte <= uartInString(index);
      uartSendInByte <= '1', '0' after 1 ns;
      wait for uartBytePeriod;
    end loop;

    uartInByte <= cr;
    uartSendInByte <= '1', '0' after 1 ns;
    wait for uartBytePeriod;

    uartSendInDone <= '1';
    wait for 1 ns;

  end process rsSendSerialString;

  rsSendSerialByte: process
    variable rxData: unsigned(uartDataBitNb-1 downto 0);
  begin
    RxD_synch <= '1';

    wait until rising_edge(uartSendInByte);
    rxData := to_unsigned(character'pos(uartInByte), rxData'length);

    RxD_synch <= '0';
    wait for uartPeriod;

    for index in rxData'reverse_range loop
      RxD_synch <= rxData(index);
      wait for uartPeriod;
    end loop;

  end process rsSendSerialByte;
   
  -- RxD_synch <= '0';
   
END ARCHITECTURE RS232;

