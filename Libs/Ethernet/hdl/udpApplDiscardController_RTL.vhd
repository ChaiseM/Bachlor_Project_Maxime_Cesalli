ARCHITECTURE RTL OF udpApplDiscardController IS

  signal ramCounter: unsigned(addressB'range);

  type discardStateType is (
    idle, waitGrant, send1, send, waitFifo, waitSendEnd
  );
  signal discardState: discardStateType;

BEGIN
  ------------------------------------------------------------------------------
                                            -- read RAM content for data to send
  countRamAddresses: process(reset, clock)
  begin
    if reset = '1' then
      ramCounter <= (others => '0');
    elsif rising_edge(clock) then
      if ramCounter = 0 then
        if discardState = send1 then
          ramCounter <= ramCounter + 1;
        end if;
      else
        if ramCounter < frameLength-1 then
          if discardState = send then
            if txFull = '0' then
              ramCounter <= ramCounter + 1;
            else
              ramCounter <= ramCounter - 1;
            end if;
          elsif discardState = waitFifo then
            if txFull = '0' then
              ramCounter <= ramCounter + 1;
            end if;
          end if;
        else
          ramCounter <= (others => '0');
        end if;
      end if;
    end if;
  end process countRamAddresses;

  ------------------------------------------------------------------------------
                                                                  -- discard FSM
  discardSequencer: process(reset, clock)
  begin
    if reset = '1' then
      discardState <= idle;
    elsif rising_edge(clock) then
      case discardState is
        when idle =>
          if sendFrame = '1' then
            discardState <= waitGrant;
          end if;
        when waitGrant =>
          if writeGranted = '1' then
            discardState <= send1;
          end if;
        when send1 =>
          discardState <= send;
        when send =>
          if ramCounter = 0 then
            discardState <= waitSendEnd;
          elsif txFull = '1' then
            discardState <= waitFifo;
          end if;
        when waitFifo =>
          if  txFull = '0' then
            discardState <= send;
          end if;
        when waitSendEnd =>
          if  sendFrame = '0' then
            discardState <= idle;
          end if;
      end case;
    end if;
  end process discardSequencer;


 -------------------------------------------------------------------------------
                                                                 -- write to UDP
  writeRequest <= '1' when
      (discardState = waitGrant) or
      (discardState = send1)     or
      (discardState = send)      or
      (discardState = waitFifo)
    else '0';

  txWr <= not txFull when discardState = send
    else '0';

  addressB <= std_ulogic_vector(ramCounter);

  destUdpPort <= std_ulogic_vector(to_unsigned(portId, destUdpPort'length));
  udpPortOut <= std_ulogic_vector(to_unsigned(portId, udpPortOut'length));
  -- Multicast: http://wiki.hevs.ch/uit/index.php5/Standards/Ethernet#Multicast_and_broadcast
  destIpAddress <= X"E00000fb";--sourceIpAddress;
  destMacAddress <= X"01005e0000fb";--sourceMacAddress;

END ARCHITECTURE RTL;
