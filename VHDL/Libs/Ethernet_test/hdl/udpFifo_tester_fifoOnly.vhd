ARCHITECTURE fifoOnly OF udpFifo_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';
  signal reset_int: std_ulogic;

  signal ipAddressU : unsigned(ipAddress'range);

  constant fifoLength : positive := 64;
  type fifoType is array(1 to fifoLength) of unsigned(rxData'range);

  signal fifoIn : fifoType;
  signal fifoInString : string(1 to fifoLength) := (others => ' ');
  signal fifoInNewString : std_ulogic;
  signal fifoInReadByte : std_ulogic;

  signal fifoOut : fifoType;
  signal fifoOutLength : positive;
  signal fifoOutString : string(1 to fifoLength) := (others => ' ');
  signal fifoOutSendData: std_ulogic;
  signal fifoOutSendString: std_ulogic;
  signal fifoOutSendDone: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- Reset and clock
  reset_int <= '1', '0' after 2*clockPeriod;
  reset <= reset_int;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                    -- Addresses
  macAddress <= X"E4AFA1" & X"39" & X"0200";
  ipAddressU  <= X"01234567";
  ipAddress <= std_ulogic_vector(ipAddressU);

  ------------------------------------------------------------------------------
                                                           -- input FIFO control
  process(clock_int)
  begin
    if rising_edge(clock_int) then
      rxRd <= '0';
      fifoInReadByte <= '0';
      fifoInNewString <= '0';
      if rxEmpty = '0' then
        rxRd <= '1';
        fifoInReadByte <= '1', '0' after 1 ns;
      else
        fifoInNewString <= '1';
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
                                                          -- output FIFO control
  process
  begin
    udpPortOut <= X"0017";
    fifoOutSendData <= '0';
    fifoOutSendString <= '0';
                                                        -- reply to UDP messages
    loop
      wait until rising_edge(rxEmpty);
      destMacAddr <= sourceMacAddr;
      destIPAddr  <= sourceIPAddr;
      destUdpport <= sourceUdpport;
      fifoOut <= (others => (others => '-'));
      fifoOutString <= (others => ' ');
      wait for clockPeriod;
      if udpPortIn = X"0007" then                                      -- echo
        fifoOutString <= fifoInString;
        fifoOutSendString <= '1', '0' after 1 ns;
      elsif udpPortIn = X"0017" then                         -- tip of the day
        fifoOutString <= "Prefer FPGAs to microprocessors                                 ";
        fifoOutSendString <= '1', '0' after 1 ns;
      elsif udpPortIn = X"14E9" then                                -- Bonjour
        if
          ( fifoIn( 5) & fifoIn( 6) = X"0001" ) and  -- 1 question
          ( fifoIn(27) & fifoIn(28) = X"0001" ) and  -- QTYPE
          ( fifoIn(29) & fifoIn(30) = X"0001" )      -- QCLASS
        then
          if
            ( fifoIn(13) = 6)                              and
            ( character'val(to_integer(fifoIn(14))) = 'f') and
            ( character'val(to_integer(fifoIn(15))) = 'p') and
            ( character'val(to_integer(fifoIn(16))) = 'g') and
            ( character'val(to_integer(fifoIn(17))) = 'a') and
            ( character'val(to_integer(fifoIn(18))) = '0') and
            ( character'val(to_integer(fifoIn(19))) = '1')
          then
            fifoOutString <= "Bonjour host discovery reply                                    ";
            fifoOutLength <= 40;
            wait for 1 ns;
            fifoOut(1 to fifoOutLength) <= (
              X"00", X"00", X"84", X"00",
              X"00", X"00", X"00", X"01", X"00", X"00", X"00", X"00",
              X"06",
              to_unsigned(character'pos('f'), rxData'length),
              to_unsigned(character'pos('p'), rxData'length),
              to_unsigned(character'pos('g'), rxData'length),
              to_unsigned(character'pos('a'), rxData'length),
              to_unsigned(character'pos('0'), rxData'length),
              to_unsigned(character'pos('1'), rxData'length),
              X"05",
              to_unsigned(character'pos('l'), rxData'length),
              to_unsigned(character'pos('o'), rxData'length),
              to_unsigned(character'pos('c'), rxData'length),
              to_unsigned(character'pos('a'), rxData'length),
              to_unsigned(character'pos('l'), rxData'length),
              X"00",
              X"00", X"01", X"80", X"01",
              X"00", X"00", X"78", X"00", X"00", X"04",
              ipAddressU(31 downto 24), ipAddressU(23 downto 16),
              ipAddressU(15 downto  8), ipAddressU( 7 downto  0)
            );
            fifoOutSendData <= '1', '0' after 1 ns;
          end if;
        end if;
      end if;
    end loop;

--    wait;
  end process;

  --============================================================================
                                                       -- Receive data from FIFO
  getFifoIn: process
    variable index: natural;
  begin
    wait on fifoInNewString, fifoInReadByte;

    if fifoInNewString = '1' then
      index := 0;
    end if;

    if fifoInReadByte = '1' then
      if index = 0 then
        fifoInString <= (others => ' ');
      end if;
      index := index + 1;
      fifoIn(index) <= unsigned(rxData);
      fifoInString(index) <= character'val(to_integer(unsigned(rxData)));
    end if;

  end process getFifoIn;

  ------------------------------------------------------------------------------
                                                            -- Send data to FIFO
  sendFifoOut: process
    variable commandRight: natural;
  begin
    txData <= (others => 'Z');
    txWr <= '0';
    fifoOutSendDone <= '0';
    wait on fifoOutSendData, fifoOutSendString;

    if rising_edge(fifoOutSendData) then
      wait until rising_edge(clock_int);
      txWr <= '1';
      for index in 1 to fifoOutLength loop
        txData <= std_ulogic_vector(fifoOut(index));
        wait until rising_edge(clock_int);
      end loop;

    elsif rising_edge(fifoOutSendString) then
      commandRight := fifoOutString'right;
      while fifoOutString(commandRight) = ' ' loop
        commandRight := commandRight-1;
      end loop;

      wait until rising_edge(clock_int);
      txWr <= '1';
      for index in fifoOutString'left to commandRight loop
        txData <= std_ulogic_vector(
          to_unsigned(character'pos(fifoOutString(index)), txData'length)
        );
        wait until rising_edge(clock_int);
      end loop;

      txData <= std_ulogic_vector(to_unsigned(character'pos(cr), txData'length));
      wait until rising_edge(clock_int);
      txData <= std_ulogic_vector(to_unsigned(character'pos(lf), txData'length));
      wait until rising_edge(clock_int);

    end if;

    fifoOutSendDone <= '1';
    wait for 1 ns;
  end process sendFifoOut;

END ARCHITECTURE fifoOnly;
