ARCHITECTURE RTL OF udpReceive IS

  type receiveStateType is (
    idle,
    receive
  );
  signal receiveState: receiveStateType;

  signal addressCounter: unsigned(udpAddress'range);

BEGIN

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  receiveFsm: process(reset, clock)
  begin
    if reset = '1' then
      receiveState <= idle;
    elsif rising_edge(clock) then
      case receiveState is
        when idle =>
          if newUdpFrame = '1' then
            receiveState <= receive;
          end if;
        when receive =>
          if addressCounter >= payloadLength then
            receiveState <= idle;
          end if;
      end case;
    end if;
  end process receiveFsm;

  tranmitControls: process(
    receiveState,
    fifoFull,
    addressCounter, payloadLength
  )
  begin
    udpDone <= '0';
    udpAddress <= (others => '-');
    fifoWrite <= '0';
    case receiveState is
      when receive =>
        if addressCounter >= payloadLength then
          udpDone <= '1';
        end if;
        if addressCounter > 0 then
          fifoWrite <= not fifoFull;
        end if;
        udpAddress <= addressCounter + 8;
      when others => null;
    end case;
  end process tranmitControls;

  fifoData <= udpData;

  ------------------------------------------------------------------------------
                                                              -- address counter
  incrementAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressCounter <= (others => '0');
    elsif rising_edge(clock) then
      if receiveState = idle then
        addressCounter <= (others => '0');
      elsif receiveState = receive then
        if fifoFull = '0' then
          addressCounter <= addressCounter + 1;
        end if;
      end if;
    end if;
  end process incrementAddress;

END ARCHITECTURE RTL;
