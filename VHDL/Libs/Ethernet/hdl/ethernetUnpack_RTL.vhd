library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF ethernetUnpack IS

  constant dataShift: natural := requiredBitNb(rx_data'length/ethData'length)-1;
  type unpackStateType is (
    idle,
    readFrameHeader, readDestAddr, readSourceAddr, readEtherType,
    transparent,
    endOfFrame, turnover
  );
  signal unpackState: unpackStateType;

  signal startOfFrame: std_ulogic;
  signal baseAddress: unsigned(rx_baseAddress'range);
  signal addressCounter: unsigned(rx_address'range);
  signal addressStep: unsigned(rx_address'range);
  signal addressLsb: std_ulogic;
  signal dataU: unsigned(rx_data'range);
  signal dataShiftRegister: unsigned(sourceMacAddr'range);
  signal frameLength: unsigned(rx_address'range);

  signal isBroadcastInt, isMulticastInt: std_ulogic;

BEGIN

  dataU <= unsigned(rx_data);

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  startOfFrame <= '1' when (unpackState = idle) and (rx_data(rx_data'high) = '1')
    else '0';

  unpackFsm: process(reset, clock)
  begin
    if reset = '1' then
      unpackState <= idle;
    elsif rising_edge(clock) then
      case unpackState is
        when idle =>
          if startOfFrame = '1' then
            unpackState <= readFrameHeader;
          end if;
        when readFrameHeader => 
          unpackState <= readDestAddr;
        when readDestAddr =>
          if addressCounter = 5 then
            if ( dataShiftRegister /= unsigned(destMacAddr) )
                and ( isBroadcastInt = '0' )
                and ( isMulticastInt = '0' ) then
              unpackState <= endOfFrame;
            else
              unpackState <= readSourceAddr;
            end if;
          end if;
        when readSourceAddr =>
          if addressCounter > 7 then
            unpackState <= readEtherType;
          end if;
        when readEtherType =>
          if addressCounter > 8 then
            unpackState <= transparent;
          end if;
        when transparent =>
          if done = '1' then
            unpackState <= endOfFrame;
          end if;
        when endOfFrame =>
          unpackState <= turnover;
        when turnover =>
          unpackState <= idle;
      end case;
    end if;
  end process unpackFsm;

  unpackControls: process(
    unpackState,
    baseAddress, addressCounter, ethAddress
  )
  begin
    rx_address <= baseAddress;
    addressStep <= to_unsigned(0, addressStep'length);
    newframe <= '0';
    case unpackState is
      when readDestAddr =>
        rx_address <= baseAddress + addressCounter;
        addressStep <= to_unsigned(1, addressStep'length);
      when readSourceAddr =>
        rx_address <= baseAddress + addressCounter;
        addressStep <= to_unsigned(1, addressStep'length);
      when readEtherType =>
        rx_address <= baseAddress + addressCounter;
        addressStep <= to_unsigned(1, addressStep'length);
      when transparent =>
        newframe <= '1';
        rx_address <= baseAddress + shift_right(ethAddress, dataShift) + 8;
      when others => null;
    end case;
  end process unpackControls;

  ------------------------------------------------------------------------------
                                                            -- read frame length
  readFrameLength: process(reset, clock)
  begin
    if reset = '1' then
      frameLength <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = readFrameHeader then
        frameLength <= resize(
          shift_right(dataU(dataU'high-1 downto 0)-1, dataShift)+1,
          frameLength'length
        );
      end if;
    end if;
  end process readFrameLength;
  
  payloadLength <=
    resize(
      shift_left(frameLength - 7, dataShift),
      payloadLength'length
    );

  ------------------------------------------------------------------------------
                                                         -- base address counter
  incrementBaseAddress: process(reset, clock)
  begin
    if reset = '1' then
      baseAddress <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = endOfFrame then
        baseAddress <= baseAddress + frameLength + 1;
      end if;
   end if;
  end process incrementBaseAddress;

  rx_baseAddress <= baseAddress;

  ------------------------------------------------------------------------------
                                                              -- address counter
  incrementAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressCounter <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = endOfFrame then
        addressCounter <= (others => '0');
      else
        addressCounter <= addressCounter + addressStep;
      end if;
   end if;
  end process incrementAddress;

  ------------------------------------------------------------------------------
                                              -- build data out of several words
  shiftData: process(reset, clock)
  begin
    if reset = '1' then
      dataShiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      dataShiftRegister <= shift_left(dataShiftRegister, dataU'length);
      dataShiftRegister(dataU'range) <= dataU;
    end if;
  end process shiftData;

  ------------------------------------------------------------------------------
                                            -- multiplex data to fifo word width
  storeSelector: process(reset, clock)
  begin
    if reset = '1' then
      addressLsb <= '0';
    elsif rising_edge(clock) then
      addressLsb <= ethAddress(0);
    end if;
  end process storeSelector;

  ethData <= rx_data(ethData'range) when addressLsb = '1'
    else rx_data(2*ethData'length-1 downto ethData'length);

  ------------------------------------------------------------------------------
                                                   -- store Ethernet information
  storeInfo: process(reset, clock)
  begin
    if reset = '1' then
      isBroadcast <= '0';
      isMulticast <= '0';
      sourceMacAddr <= (others => '0');
      etherType <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = readDestAddr then
        isBroadcast <= isBroadcastInt;
        isMulticast <= isMulticastInt;
      end if;
      if unpackState = readSourceAddr then
        sourceMacAddr <= std_ulogic_vector(dataShiftRegister);
      end if;
      if unpackState = readEtherType then
        etherType <= std_ulogic_vector(dataShiftRegister(etherType'range));
      end if;
    end if;
  end process storeInfo;

  isBroadcastInt <= '1' when
    shift_right(dataShiftRegister, dataShiftRegister'length/2) = X"FFFFFF"
    else '0';
  isMulticastInt <= '1' when
    shift_right(dataShiftRegister, dataShiftRegister'length/2) = X"01005E"
    else '0';

END ARCHITECTURE RTL;
