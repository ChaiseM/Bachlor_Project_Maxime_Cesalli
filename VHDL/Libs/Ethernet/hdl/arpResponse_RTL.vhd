ARCHITECTURE RTL OF arpResponse IS

  -- Constant to prevent locally static expression in ISE needs to be set to ipAddressBitNb and macAddressBitNb
  constant macAddress_length : positive := 48;
  constant ipAddress_length  : positive := 32;
  
  constant arpFrameLength: positive := 4*7;
  constant shaOffset: positive :=  8;
  constant spaOffset: positive := 14;
  constant thaOffset: positive := 18;
  constant tpaOffset: positive := 24;

  type arpStateType is (
    idle,
    readFrame,
    waitWrite1, waitWrite2,
    writeFrame,
    waitNext
  );
  signal arpState: arpStateType;

  signal addressCounter: unsigned(readAddress'range);
  signal inputShiftRegister: unsigned(macAddress'range);
  signal isArpRequest: std_ulogic;
  signal sourceMacAddress: unsigned(macAddress'range);
  signal sourceIpAddress: unsigned(ipAddress'range);

BEGIN
  ------------------------------------------------------------------------------
                                                                    -- sequencer
  arpFsm: process(reset, clock)
  begin
    if reset = '1' then
      arpState <= idle;
    elsif rising_edge(clock) then
      case arpState is
        when idle =>
          if en = '1' then
            arpState <= readFrame;
          end if;
        when readFrame =>
          if addressCounter >= arpFrameLength then
            arpState <= waitWrite1;
          end if;
        when waitWrite1 =>
          if isArpRequest = '0' then
            arpState <= waitNext;
          elsif ipBusy = '0' then
            arpState <= waitWrite2;
          end if;
        when waitWrite2 =>
          if ready = '1' then
            arpState <= writeFrame;
          end if;
        when writeFrame =>
          if addressCounter >= arpFrameLength-1 then
            arpState <= waitNext;
          end if;
        when waitNext =>
          if en = '0' then
            arpState <= idle;
          elsif newEthFrame = '1' then
            arpState <= readFrame;
          end if;
      end case;
    end if;
  end process arpFsm;

  ------------------------------------------------------------------------------
                                                              -- synchronization
  done <= '1' when arpState = waitWrite1 else '0';
  arpSelected <= '1' when (arpState = waitWrite2) or (arpState = writeFrame)
    else '0';
  sendFrame <= '1' when (arpState = waitWrite2) or (arpState = writeFrame)
    else '0';
  write <= '1' when arpState = writeFrame
    else '0';

  ------------------------------------------------------------------------------
                                                              -- address counter
  incrementReadAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressCounter <= (others => '0');
    elsif rising_edge(clock) then
      if  (arpState = idle) or
          (arpState = waitWrite2) or
          (arpState = waitNext) then
        addressCounter <= (others => '0');
      else
        addressCounter <= addressCounter + 1;
      end if;
   end if;
  end process incrementReadAddress;

  readAddress <= addressCounter;
  writeAddress <= addressCounter;

  ------------------------------------------------------------------------------
                                                           -- read request frame
  storeInputData: process(reset, clock)
  begin
    if reset = '1' then
      inputShiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      inputShiftRegister <= shift_left(inputShiftRegister, readData'length);
      inputShiftRegister(readData'range) <= unsigned(readData);
   end if;
  end process storeInputData;

  checkArpRequest: process(reset, clock)
  begin
    if reset = '1' then
      isArpRequest <= '0';
      sourceMacAddress <= (others => '0');
      sourceIpAddress <= (others => '0');
    elsif rising_edge(clock) then
                                                         -- check request info
      if addressCounter = 1 then
        isArpRequest <= '1';
      elsif addressCounter = 7 then
        if inputShiftRegister /= X"000108000604" then
          isArpRequest <= '0';
        end if;
      elsif addressCounter = 9 then
        if inputShiftRegister(15 downto 0) /= X"0001" then
          isArpRequest <= '0';
        end if;
      elsif addressCounter = 29 then
        if inputShiftRegister(ipAddress'range) /= unsigned(ipAddress) then
          isArpRequest <= '0';
        end if;
      end if;
                                                          -- store MAC address
      if addressCounter = 17 then
        if arpState = readFrame then
          sourceMacAddress <= inputShiftRegister;
        end if;
      end if;
                                                           -- store IP address
      if addressCounter = 21 then
        if arpState = readFrame then
          sourceIpAddress <= inputShiftRegister(sourceIpAddress'range);
        end if;
      end if;
   end if;
  end process checkArpRequest;

  ------------------------------------------------------------------------------
                                                         -- write response frame
  buildArpAnswer: process(
    arpState, addressCounter,
    macAddress, ipAddress,
    sourceMacAddress, sourceIpAddress
  )
  begin
    arpData <= (others => '-');
    if arpState = writeFrame then
                                                                   -- ARP header
      case to_integer(addressCounter) is
        when  0 => arpData <= X"00";    -- HTYPE
        when  1 => arpData <= X"01";    --
        when  2 => arpData <= X"08";    -- PTYPE
        when  3 => arpData <= X"00";    --
        when  4 => arpData <= X"06";    -- HLEN
        when  5 => arpData <= X"04";    -- PLEN
        when  6 => arpData <= X"00";    -- OPER
        when  7 => arpData <= X"02";    --
        when others => null;
      end case;
                                                                          -- SHA
      case to_integer(addressCounter)-shaOffset is
        when 0 to macAddress_length/8-1 =>
          arpData <= std_ulogic_vector(
            resize(
              shift_right(
                unsigned(macAddress),
                ( macAddress'length/8-1 - to_integer(addressCounter-shaOffset) )
                  *arpData'length
              ),
              arpData'length
            )
          );
        when others => null;
      end case;
                                                                          -- SPA
      case to_integer(addressCounter)-spaOffset is
        when 0 to ipAddress_length/8-1 =>
          arpData <= std_ulogic_vector(
            resize(
              shift_right(
                unsigned(ipAddress),
                ( ipAddress'length/8-1 - to_integer(addressCounter-spaOffset) )
                  *arpData'length
              ),
              arpData'length
            )
          );
        when others => null;
      end case;
                                                                          -- THA
      case to_integer(addressCounter)-thaOffset is
        --when 0 to sourceMacAddress'length/8-1 =>
        when 0 to macAddress_length/8-1 =>
          arpData <= std_ulogic_vector(
            resize(
              shift_right(
                unsigned(sourceMacAddress),
                ( sourceMacAddress'length/8-1 - to_integer(addressCounter-thaOffset) )
                  *arpData'length
              ),
              arpData'length
            )
          );
        when others => null;
      end case;
                                                                          -- TPA
      case to_integer(addressCounter)-tpaOffset is
        --when 0 to sourceIpAddress'length/8-1 =>
        when 0 to ipAddress_length/8-1 =>
          arpData <= std_ulogic_vector(
            resize(
              shift_right(
                unsigned(sourceIpAddress),
                ( sourceIpAddress'length/8-1 - to_integer(addressCounter-tpaOffset) )
                  *arpData'length
              ),
              arpData'length
            )
          );
        when others => null;
      end case;
    end if;
  end process buildArpAnswer;

END ARCHITECTURE RTL;
