ARCHITECTURE RTL OF udpTransmit IS

  type transmitStateType is (
    idle, waitReady,
    transmit
  );
  signal transmitState: transmitStateType;

  signal addressCounter: unsigned(udpAddress'range);

BEGIN

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  transmitFsm: process(reset, clock)
  begin
    if reset = '1' then
      transmitState <= idle;
    elsif rising_edge(clock) then
      case transmitState is
        when idle =>
          if fifoEmpty = '0' then
            transmitState <= waitReady;
          end if;
        when waitReady =>
          if udpReady = '1' then
            transmitState <= transmit;
          end if;
        when transmit =>
          if fifoEmpty = '1' then
            transmitState <= idle;
          end if;
      end case;
    end if;
  end process transmitFsm;

  tranmitControls: process(
    transmitState,
    fifoEmpty, fifoData,
    addressCounter
  )
  begin
    sendUdpFrame <= '0';
    udpAddress <= (others => '-');
    udpData <= (others => '-');
    udpWrite <= '0';
    fifoRead <= '0';
    case transmitState is
      when waitReady =>
        sendUdpFrame <= '1';
      when transmit =>
        sendUdpFrame <= '1';
        fifoRead <= not fifoEmpty;
        udpWrite <= not fifoEmpty;
        udpAddress <= addressCounter;
        udpData <= fifoData;
      when others => null;
    end case;
  end process tranmitControls;

  ------------------------------------------------------------------------------
                                                              -- address counter
  incrementAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressCounter <= (others => '0');
    elsif rising_edge(clock) then
      if transmitState = idle then
        addressCounter <= (others => '0');
      elsif transmitState = transmit then
        addressCounter <= addressCounter + 1;
      end if;
    end if;
  end process incrementAddress;

END ARCHITECTURE RTL;
