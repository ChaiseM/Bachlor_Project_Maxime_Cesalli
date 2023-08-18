ARCHITECTURE RTL OF udpApplReg IS

  constant regMaxFrameLength : positive := 1500-20-8;
  
  constant startbyte       : natural  := 0;
  constant addrSize        : positive := 1;
  constant dataSize        : positive := 4;

  signal udpWord           : unsigned(2*udpData'length-1 downto 0);
  signal reg_addr          : natural range 0 to regIn_RegNb;
  signal reg_counter       : natural range 0 to regIn_RegNb;
  signal reg_in_en_int     : std_ulogic_vector(reg_in_en'range);
  signal dataValid         : std_ulogic;

  signal regPacketLength   : natural := regOut_RegNb * (addrSize + dataSize);
  signal regPacket         : unsigned(txData'range);
  signal reg_out_en_int    : std_ulogic_vector(reg_Out_en'range);
  
  signal functionSelected  : std_ulogic;
  signal payloadInCounter  : natural range 0 to regMaxFrameLength;
  signal payloadOutCounter : natural range 0 to regMaxFrameLength;

  type RegInStateType is (
    idle, readPacket, writeRegister,
    endOfPacket
  );
  signal RegInState: RegInStateType;

  type RegOutStateType is (
    idle, 
    sendRequest, startwritePacket, writePacket,
    endOfPacket
  );
  signal RegOutState: RegOutStateType;
BEGIN

  ------------------------------------------------------------------------------
                                                                -- read from UDP
  functionSelected <= '1' when unsigned(udpPortIn) = regPortId
    else '0';
  isSelected <= functionSelected;

  readEn <= functionSelected;

  dataValid <= functionSelected and udpDataValid;

  ------------------------------------------------------------------------------
                                                                 -- write to UDP
  --destUdpPort <= sourceUdpPort;
  udpPortOut <= udpPortIn;

  --destIpAddress <= X"E00000FB";
  --destMacAddress <= X"01005E0000FB";

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
                                                                  -- regIn FSM
  regInSequencer: process(reset, clock)
  begin
    if reset = '1' then
      regInState <= idle;
    elsif rising_edge(clock) then
      case regInState is
        when idle =>
          if (functionSelected = '1') and (udpDataValid = '1') then
            regInState <= readPacket;
          end if;
        when readPacket =>
          if udpDataValid = '0' then
            regInState <= writeRegister;
          end if;
        when writeRegister =>
          regInState <= endOfPacket;
        when endOfPacket =>
          regInState <= idle;
      end case;
    end if;
  end process regInSequencer;

  countPayloadInPosition: process(reset, clock)
  begin
    if reset = '1' then
      payloadInCounter <= 0;
    elsif rising_edge(clock) then
      if regInState = idle then
        if (functionSelected = '1') and (udpDataValid = '1') then
          payloadInCounter <= payloadInCounter + 1;
        else
          payloadInCounter <= 0;
        end if;
      elsif regInState = readPacket then
        if udpDataValid = '1' then
          payloadInCounter <= payloadInCounter + 1;
        end if;
      end if;
    end if;
  end process countPayloadInPosition;
  
  macIpAddress: process (reset, clock)
  begin
    if reset = '1' then
      destIpAddress  <= X"E00000FB";
      destMacAddress <= X"01005E0000FB";
      destUdpPort    <= std_ulogic_vector(to_unsigned(regPortId,destUdpPort'length));
    elsif rising_edge(clock) then
       if regInState = writeRegister then
         destIpAddress  <= sourceIpAddress;
         destMacAddress <= sourceMacAddress;
         destUdpPort    <= sourceUdpPort;
       end if;
    end if;
  end process macIpAddress;

  ------------------------------------------------------------------------------
                                                     -- test query frame content
  readData: process(reset, clock)
  begin
    if reset = '1' then
      reg_in_data   <= (others => (others => '0'));
      reg_in_en     <= (others => '0');
      reg_in_en_int <= (others => '0');
      reg_addr      <= 0;
      reg_counter   <= 0;
    elsif rising_edge(clock) then
      reg_in_en     <= (others => '0');
      if regInState = endOfPacket then
        reg_in_en_int <= (others => '0');
        reg_in_en     <= reg_in_en_int;
        reg_addr      <= 0;
        reg_counter   <= 0;
      elsif dataValid = '1' then
        if payloadInCounter = startbyte + (reg_counter * (addrSize + dataSize)) then 
          reg_addr <= to_integer(unsigned(udpData));
          reg_in_en_int(to_integer(unsigned(udpData))) <= '1';
        elsif payloadInCounter = startbyte + addrSize + (reg_counter * (addrSize + dataSize)) + 0 then
          reg_in_data(reg_addr)(31 downto 24) <= udpData;
        elsif payloadInCounter = startbyte + addrSize + (reg_counter * (addrSize + dataSize)) + 1 then
          reg_in_data(reg_addr)(23 downto 16) <= udpData;
        elsif payloadInCounter = startbyte + addrSize + (reg_counter * (addrSize + dataSize)) + 2 then
          reg_in_data(reg_addr)(15 downto 8)  <= udpData;
        elsif payloadInCounter = startbyte + addrSize + (reg_counter * (addrSize + dataSize)) + 3 then
          reg_in_data(reg_addr)(7 downto 0)   <= udpData;
          reg_counter <= reg_counter + 1;
        end if;
      end if;
    end if;
  end process readData;

  ------------------------------------------------------------------------------
  -- Send Frames
  ------------------------------------------------------------------------------
  writeRequest <= '1' when
      (regOutState = sendRequest) or
      (regOutState = startwritePacket) or
      (regOutState = writePacket)
    else '0';
 
  txData <= std_ulogic_vector(regPacket);
  txWr <= '1' when (regOutState = writePacket) and (txFull = '0')
    else '0';

  ------------------------------------------------------------------------------
                                                                  -- regOut FSM
  regOutSequencer: process(reset, clock)
  begin
    if reset = '1' then
      regOutState <= idle;
    elsif rising_edge(clock) then
      case regOutState is
        when idle =>
          if ( unsigned(reg_Out_en) > 0 ) then
            regOutState <= sendRequest;
          end if;
        when sendRequest =>
          if (writeGranted = '1') then
            regOutState <= startwritePacket;
          end if;
        when startwritePacket =>
          regOutState <= writePacket;
        when writePacket =>
          if payloadOutCounter = regPacketLength-1 then
            regOutState <= endOfPacket;
          end if;
        when endOfPacket =>
          regOutState <= idle;
      end case;
    end if;
  end process regOutSequencer;

  countPacketLength: process(regOutState, reg_Out_en)
    variable regPacketLength_var : natural := 0;
  begin
    if RegOutState = idle then
      if ( unsigned(reg_Out_en) > 0 ) then
        regPacketLength_var := 0;
        for i in 0 to reg_Out_en'high loop
          if reg_Out_en(i) = '1' then
            regPacketLength_var := regPacketLength_var + (addrSize + dataSize);
          end if;
        end loop;
      end if;
    end if;
    regPacketLength <= regPacketLength_var;
  end process countPacketLength;

  countPayloadOutPosition: process(reset, clock)
  begin
    if reset = '1' then
      payloadOutCounter   <= 0;
      reg_out_en_int <= (others => '0');
    elsif rising_edge(clock) then
      if RegOutState = idle then
        payloadOutCounter   <= 0;
        reg_out_en_int <= reg_out_en;
      elsif RegOutState = startwritePacket then
        payloadOutCounter <= 0;
      elsif RegOutState = writePacket then
        if txFull = '0' then
          payloadOutCounter <= payloadOutCounter + 1;
        end if;
      end if;
    end if;
  end process countPayloadOutPosition;

  ------------------------------------------------------------------------------
                                                   -- build reg packet
 
  buildRegPacket: process(
    regOutState,
    reg_Out_en_int, payloadOutCounter,
    reg_Out_data
  )
  begin
    regPacket <= (others => '-');
    if regOutState = writePacket then
      for i in 0 to reg_Out_en_int'high loop
        if reg_Out_en_int(i) = '1' then
          if (payloadOutCounter = 0+i*5) then 
            regPacket <= to_unsigned(i, regPacket'length);
          elsif (payloadOutCounter = 1+i*5) then
            regPacket <= unsigned(reg_Out_data(i)(31 downto 24));
          elsif (payloadOutCounter = 2+i*5) then
            regPacket <= unsigned(reg_Out_data(i)(23 downto 16));
          elsif (payloadOutCounter = 3+i*5) then
            regPacket <= unsigned(reg_Out_data(i)(15 downto 8));
          elsif (payloadOutCounter = 4+i*5) then
            regPacket <= unsigned(reg_Out_data(i)(7  downto 0));
          end if;
        end if;
      end loop;
    end if;
  end process buildRegPacket;

END ARCHITECTURE RTL;
