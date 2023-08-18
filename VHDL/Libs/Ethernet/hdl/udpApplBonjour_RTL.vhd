ARCHITECTURE RTL OF udpApplBonjour IS
  
  -- Constant to prevent locally static expression in ISE (needs to be set to your bonjourName'length)
  constant bonjourName_length : positive := 6;
  
  constant bonjourMaxFrameLength : positive := 1500-20-8;
  
  constant QDCountIndex : positive := 5;
  constant QLengthIndex : positive := 12;
  signal QNameIndex : positive range 1 to bonjourMaxFrameLength;
  signal QTypeIndex : positive range 1 to bonjourMaxFrameLength;
  signal QClassIndex : positive range 1 to bonjourMaxFrameLength;
  signal udpWord: unsigned(2*udpData'length-1 downto 0);

  --constant bonjourHostAnswerLength : positive := 34 + bonjourName'length;
  constant bonjourHostAnswerLength : positive := 34 + bonjourName_length;
  signal bonjourHostAnswer: unsigned(txData'range);

  signal functionSelected: std_ulogic;
  signal isHostDiscovery: std_ulogic;
  signal isDeviceDiscovery: std_ulogic;
  signal payloadCounter: natural range 0 to bonjourMaxFrameLength;

  type bonjourStateType is (
    idle, readRequest,
    startWriteAnswer, writeHostAnswer,
    endOfRequest
  );
  signal bonjourState: bonjourStateType;

BEGIN
  ------------------------------------------------------------------------------
                                                                -- read from UDP
  functionSelected <= '1' when unsigned(udpPortIn) = bonjourPortId
    else '0';
  isSelected <= functionSelected;

  readEn <= functionSelected;

  ------------------------------------------------------------------------------
                                                                 -- write to UDP
  writeRequest <= '1' when
      (bonjourState = readRequest) or
      (bonjourState = startWriteAnswer) or
      (bonjourState = writeHostAnswer)
    else '0';

  txData <= std_ulogic_vector(bonjourHostAnswer);
  txWr <= '1' when (bonjourState = writeHostAnswer) and (txFull = '0')
    else '0';

  destUdpPort <= sourceUdpPort;
  udpPortOut <= udpPortIn;
  destIpAddress <= X"E00000FB";
  destMacAddress <= X"01005E0000FB";

  ------------------------------------------------------------------------------
                                                          -- pack bytes to words

  packBytesToWord: process(reset, clock)
  begin
    if reset = '1' then
      udpWord <= (others => '0');
    elsif rising_edge(clock) then
      udpWord <= shift_left(udpWord, udpData'length);
      udpWord(udpData'range) <= unsigned(udpData);
    end if;
  end process packBytesToWord;

  ------------------------------------------------------------------------------
                                                                  -- bonjour FSM
  bonjourSequencer: process(reset, clock)
  begin
    if reset = '1' then
      bonjourState <= idle;
    elsif rising_edge(clock) then
      case bonjourState is
        when idle =>
          if (functionSelected = '1') and (udpDataValid = '1') then
            bonjourState <= readRequest;
          end if;
        when readRequest =>
          if udpDataValid = '0' then
            bonjourState <= startWriteAnswer;
          end if;
        when startWriteAnswer =>
          if writeGranted = '1' then
            if (isHostDiscovery = '1') and (isDeviceDiscovery = '1') then
              bonjourState <= writeHostAnswer;
            else
              bonjourState <= endOfRequest;
            end if;
          end if;
        when writeHostAnswer =>
          if payloadCounter = bonjourHostAnswerLength-1 then
            bonjourState <= endOfRequest;
          end if;
        when endOfRequest =>
          --if functionSelected = '0' then
            bonjourState <= idle;
          --end if;
      end case;
    end if;
  end process bonjourSequencer;

  countPayloadPosition: process(reset, clock)
  begin
    if reset = '1' then
      payloadCounter <= 0;
    elsif rising_edge(clock) then
      if bonjourState = idle then
        payloadCounter <= 0;
      elsif bonjourState = readRequest then
        payloadCounter <= payloadCounter + 1;
      elsif bonjourState = startWriteAnswer then
        payloadCounter <= 0;
      elsif bonjourState = writeHostAnswer then
        if txFull = '0' then
          payloadCounter <= payloadCounter + 1;
        end if;
      end if;
    end if;
  end process countPayloadPosition;

  ------------------------------------------------------------------------------
                                                     -- test query frame content
  checkHostDiscovery: process(reset, clock)
  begin
    if reset = '1' then
      isHostDiscovery <= '1';
    elsif rising_edge(clock) then
      if payloadCounter = 0 then
        isHostDiscovery <= '1';
      elsif payloadCounter = QDCountIndex then 
        if udpWord /= 1 then
          isHostDiscovery <= '0';
        end if;
      elsif payloadCounter = QTypeIndex then 
        if udpWord /= 1 then
          isHostDiscovery <= '0';
        end if;
      elsif payloadCounter = QClassIndex then 
        if udpWord /= 1 then
          isHostDiscovery <= '0';
        end if;
      end if;
    end if;
  end process checkHostDiscovery;

  checkDeviceName: process(reset, clock)
    variable nameIndex: integer;
  begin
    if reset = '1' then
      isDeviceDiscovery <= '1';
      QNameIndex <= QLengthIndex;
    elsif rising_edge(clock) then
      nameIndex := payloadCounter - QLengthIndex + 1;
      if payloadCounter = 0 then
        isDeviceDiscovery <= '1';
        QNameIndex <= QLengthIndex;
      elsif payloadCounter = QLengthIndex-1 then 
        QNameIndex <= QLengthIndex + to_integer(unsigned(udpData));
      elsif (payloadCounter >= QLengthIndex) and (payloadCounter < QNameIndex) then 
        if bonjourState = readRequest then
          if to_integer(unsigned(udpData)) /= character'pos(bonjourName(nameIndex)) then
            isDeviceDiscovery <= '0';
          end if;
        end if;
      end if;
    end if;
  end process checkDeviceName;

  QTypeIndex  <= QNameIndex + 7 + 2;
  QClassIndex <= QTypeIndex + 2;

  ------------------------------------------------------------------------------
                                                   -- build answer frame content
  buildBonjourAnswer: process(
    bonjourState, payloadCounter,
    ipAddress
  )
  begin
    bonjourHostAnswer <= (others => '-');
    if bonjourState = writeHostAnswer then
                                                                   -- DNS header
      case payloadCounter is
        when  0 => bonjourHostAnswer <= X"00";          -- ID
        when  1 => bonjourHostAnswer <= X"00";          --
        when  2 => bonjourHostAnswer <= X"84";          -- Flags
        when  3 => bonjourHostAnswer <= X"00";          --
        when  4 => bonjourHostAnswer <= X"00";          -- QDcount
        when  5 => bonjourHostAnswer <= X"00";          --
        when  6 => bonjourHostAnswer <= X"00";          -- ANcount
        when  7 => bonjourHostAnswer <= X"01";          --
        when  8 => bonjourHostAnswer <= X"00";          -- NScount
        when  9 => bonjourHostAnswer <= X"00";          --
        when 10 => bonjourHostAnswer <= X"00";          -- ARcount
        when 11 => bonjourHostAnswer <= X"00";          --
        when others => null;
      end case;
                                                                 -- machine name
      case payloadCounter-QLengthIndex is
        when  0 =>
          bonjourHostAnswer <= to_unsigned(
            bonjourName'length,
            bonjourHostAnswer'length
          );
        --when  1 to bonjourName'length =>
        when  1 to bonjourName_length =>
          bonjourHostAnswer <= to_unsigned(
            character'pos(bonjourName(payloadCounter-QLengthIndex)),
            bonjourHostAnswer'length
          );
        when others => null;
      end case;
                                                                     -- ".local"
      --case payloadCounter-QLengthIndex-bonjourName'length is
      case payloadCounter-QLengthIndex-bonjourName_length is
        when  1 => bonjourHostAnswer <= X"05";          -- length
        when  2 => bonjourHostAnswer <= X"6C";          -- name: "local"
        when  3 => bonjourHostAnswer <= X"6F";          --
        when  4 => bonjourHostAnswer <= X"63";          --
        when  5 => bonjourHostAnswer <= X"61";          --
        when  6 => bonjourHostAnswer <= X"6C";          --
        when  7 => bonjourHostAnswer <= X"00";          -- end of string
        when  8 => bonjourHostAnswer <= X"00";          -- QType: address
        when  9 => bonjourHostAnswer <= X"01";          --
        when 10 => bonjourHostAnswer <= X"80";          -- QClass
        when 11 => bonjourHostAnswer <= X"01";          --
        when 12 => bonjourHostAnswer <= X"00";          -- TTL
        when 13 => bonjourHostAnswer <= X"00";          --
        when 14 => bonjourHostAnswer <= X"00";          --
        when 15 => bonjourHostAnswer <= X"78";          --
        when 16 => bonjourHostAnswer <= X"00";          -- Data Length
        when 17 => bonjourHostAnswer <= X"04";          --
        when others => null;
      end case;
                                                                   -- IP address
      case payloadCounter is
        when bonjourHostAnswerLength-4 to bonjourHostAnswerLength-1 =>
          bonjourHostAnswer <=                          -- IP address
            resize(
              shift_right(
                unsigned(ipAddress),
                (bonjourHostAnswerLength-1-payloadCounter)
                  *bonjourHostAnswer'length
              ),
              bonjourHostAnswer'length
            );
        when others => null;
      end case;
    end if;
  end process buildBonjourAnswer;

END ARCHITECTURE RTL;
