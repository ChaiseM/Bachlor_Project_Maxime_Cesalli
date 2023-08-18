ARCHITECTURE RTL OF udpApplEcho IS

  signal functionSelected: std_ulogic;

  signal udpDataReg: std_ulogic_vector(udpData'range);
  signal udpDataRegEn: std_ulogic;

  type echoStateType is (
    idle, selected,
    waitGrant, transmit, waitFifo
  );
  signal echoState: echoStateType;

BEGIN

  functionSelected <= '1' when unsigned(udpPortIn) = echoPortId
    else '0';
  isSelected <= functionSelected;

  ------------------------------------------------------------------------------
                                                                     -- echo FSM
  echoSequencer: process(reset, clock)
  begin
    if reset = '1' then
      echoState <= idle;
    elsif rising_edge(clock) then
      case echoState is
        when idle =>
          if functionSelected = '1' then
            echoState <= selected;
          end if;
        when selected =>
          if udpDataValid = '1' then
            echoState <= waitGrant;
          elsif functionSelected = '0' then
            echoState <= idle;
          end if;
        when waitGrant =>
          if writeGranted = '1' then
            echoState <= transmit;
          end if;
        when transmit =>
          if txFull = '1' then
            echoState <= waitFifo;
          elsif udpDataValid = '0' then
            echoState <= selected;
          end if;
        when waitFifo =>
          if txFull = '0' then
            echoState <= transmit;
          end if;
      end case;
    end if;
  end process echoSequencer;

 -------------------------------------------------------------------------------
                                                                -- read from UDP
  readEn <= not txFull when (echoState = selected) or (echoState = transmit)
    else '0';

  udpDataRegEn <= not txFull when (echoState = selected) or (echoState = transmit)
    else '0';

  storeData: process(reset, clock)
  begin
    if reset = '1' then
      udpDataReg <= (others => '0');
    elsif rising_edge(clock) then
      if udpDataRegEn = '1' then
        udpDataReg <= udpData;
      end if;
    end if;
  end process storeData;

 -------------------------------------------------------------------------------
                                                                 -- write to UDP
  writeRequest <= '1' when
      (echoState = waitGrant) or
      (echoState = transmit) or
      (echoState = waitFifo)
    else '0';

  txData <= udpDataReg;

  txWr <= not txFull when echoState = transmit
    else '0';

  destUdpPort <= sourceUdpPort;
  udpPortOut <= udpPortIn;
  destIpAddress <= sourceIpAddress;
  destMacAddress <= sourceMacAddress;

END ARCHITECTURE RTL;
