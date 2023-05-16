LIBRARY std;
  USE std.textio.all;
LIBRARY Common_test;
  USE Common_test.testUtils.all;

ARCHITECTURE test OF miimFifo_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal txRegAddress_int: natural;
  signal txData_int: natural;
  constant mdSendTime: time := 4000*clockPeriod;

  signal rxDataReg: std_ulogic_vector(rxData'range);

  constant separator : string(1 to 80) := (others => '-');
  constant indent    : string(1 to  2) := (others => ' ');

BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clocks
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                 -- FIFO control
  process
  begin
    enMiim <= '1';
    txRegAddress_int <= 0;
    txData_int <= 0;
    txRdWr <= '0';
    txWr <= '0';
    wait for mdSendTime/10;
    print(cr & separator);
                                                          -- write to register 0
    print(sprintf("%6.1tu", now) & ": Writing register 0");
    txRdWr <= '0';
    txRegAddress_int <= 0;
    txData_int <= 16#CC33#;
    wait until falling_edge(clock_int);
    txWr <= '1', '0' after clockPeriod;
    wait for mdSendTime;
                                                          -- write to register 1
    print(sprintf("%6.1tu", now) & ": Writing register 1");
    txRdWr <= '0';
    txRegAddress_int <= 1;
    txData_int <= 16#55AA#;
    wait until falling_edge(clock_int);
    txWr <= '1', '0' after clockPeriod;
    wait for mdSendTime;
                                                         -- read from register 0
    print(sprintf("%6.1tu", now) & ": Reading from register 0");
    txRdWr <= '1';
    txRegAddress_int <= 0;
    wait until falling_edge(clock_int);
    txWr <= '1', '0' after clockPeriod;
    wait for mdSendTime;
                                                         -- read from register 1
    print(sprintf("%6.1tu", now) & ": Reading from register 0");
    txRdWr <= '1';
    txRegAddress_int <= 1;
    wait until falling_edge(clock_int);
    txWr <= '1', '0' after clockPeriod;
    wait for mdSendTime;
                                                     -- block write to registers
    print(sprintf("%6.1tu", now) & ": Writing registers 0 to 7");
    wait until falling_edge(clock_int);
    for index in 0 to 7 loop
      txRdWr <= '0';
      txRegAddress_int <= index;
      txData_int <= 16#FC00# + index;
      txWr <= '1';
      wait for clockPeriod;
      txWr <= '0';
      wait for clockPeriod;
    end loop;
    wait for 6*mdSendTime;
                                                         -- read from register 0
    print(sprintf("%6.1tu", now) & ": Reading from register 0");
    txRdWr <= '1';
    txRegAddress_int <= 0;
    wait until falling_edge(clock_int);
    txWr <= '1', '0' after clockPeriod;
    wait for mdSendTime;
                                                            -- end of simulation
    wait;
  end process;

  ------------------------------------------------------------------------------
                                                                -- data readback
  process
  begin
    rxRd <= '0';
    wait until rxEmpty = '0';
    wait for clockPeriod/10;
    rxRd <= '1', '0' after clockPeriod;
    rxDataReg <= rxData;
    wait for clockPeriod;
  end process;

  ------------------------------------------------------------------------------
                                                         -- conversion functions
  txAddr <= to_unsigned(txRegAddress_int, txAddr'length);
  txData <= std_ulogic_vector(to_unsigned(txData_int, txdata'length));

END ARCHITECTURE test;
