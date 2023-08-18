ARCHITECTURE RTL OF ipUnpack IS

  type unpackStateType is (idle, readHeader, checkIp, transparent, endOfFrame);
  signal unpackState: unpackStateType;

  signal addressCounter: unsigned(ethAddress'range);
  signal addressStep: unsigned(ethAddress'range);
  signal dataU: unsigned(ethData'range);
  signal dataShiftRegister: unsigned(destIpAddr'range);

  signal checksumCalcEn: std_ulogic;
  signal headerData16: unsigned(15 downto 0);
  signal checksum: unsigned(15+1 downto 0);
  signal checksumInv: unsigned(15 downto 0);

  signal udpChecksumCalcEn: std_ulogic;
  signal udpChecksum: unsigned(udpPseudoHeaderChecksum'range);

  constant multicastShift : positive := dataShiftRegister'length*3/4;
  constant minMulticastAddress : natural := 224;
  constant maxMulticastAddress : natural := 239;
  constant broadcastMask : std_ulogic_vector(destIpAddr'range) := X"FFFFFF00";
  signal isIpAddress: std_ulogic;
  signal isMulticastInt: std_ulogic;
  signal isBroadcastInt: std_ulogic;

BEGIN

  dataU <= unsigned(ethData);

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  unpackFsm: process(reset, clock)
  begin
    if reset = '1' then
      unpackState <= idle;
      isMulticast <= '0';
      isBroadcast <= '0';
    elsif rising_edge(clock) then
      case unpackState is
        when idle =>
          if (enIpv4 = '1') and (newEthFrame = '1') then
            unpackState <= readHeader;
          end if;
        when readHeader =>
          if addressCounter >= 20 then
            unpackState <= checkIp;
          end if;
          isMulticast <= '0';
          isBroadcast <= '0';
        when checkIp =>
          if ( isIpAddress = '0' ) and
             ( isBroadcastInt = '0' ) and
             ( isMulticastInt = '0' ) then
            unpackState <= endOfFrame;
          elsif checksumInv /= 0 then
            unpackState <= endOfFrame;
          else
            unpackState <= transparent;
          end if;
          isMulticast <= macMulticast and isMulticastInt;
          isBroadcast <= macBroadcast and isBroadcastInt;
        when transparent =>
          if ipDone = '1' then
            unpackState <= endOfFrame;
          end if;
        when endOfFrame =>
          unpackState <= idle;
      end case;
      if enIpv4 = '0' then
        isMulticast <= '0';
        isBroadcast <= '0';
      end if;
    end if;
  end process unpackFsm;

  isIpAddress <= '1' when dataShiftRegister = unsigned(destIpAddr)
    else '0';

  isMulticastInt <= '1' when
    ( shift_right(dataShiftRegister, multicastShift) >= minMulticastAddress ) and
    ( shift_right(dataShiftRegister, multicastShift) <= maxMulticastAddress )
    else '0';
  
  isBroadcastInt <= '1' when -- e.g. 192.168.111.255
    ( 
      (std_ulogic_vector(dataShiftRegister) and broadcastMask) =
      (destIpAddr                           and broadcastMask)
    ) and (
      (std_ulogic_vector(dataShiftRegister) or broadcastMask) =
      std_ulogic_vector(to_signed(-1, dataShiftRegister'length))
    )
    else '1' when  -- 255.255.255.255
    (
      std_ulogic_vector(dataShiftRegister) =
      std_ulogic_vector(to_signed(-1, dataShiftRegister'length))
    )
    else '0';

  unpackControls: process(
    unpackState,
    addressCounter, ipAddress
  )
  begin
    ethAddress <= addressCounter;
    addressStep <= to_unsigned(0, addressStep'length);
    newIpFrame <= '0';
    ethDone <= '0';
    case unpackState is
      when readHeader =>
        addressStep <= to_unsigned(1, addressStep'length);
      when transparent =>
        newIpFrame <= '1';
        ethAddress <= ipAddress + 20;
      when endOfFrame =>
        ethDone <= '1';
      when others => null;
    end case;
  end process unpackControls;

  ------------------------------------------------------------------------------
                                                              -- address counter
  incrementAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressCounter <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = idle then
        addressCounter <= (others => '0');
      else
        addressCounter <= addressCounter + addressStep;
      end if;
   end if;
  end process incrementAddress;

  ------------------------------------------------------------------------------
                                              -- build data out of several words
  ipData <= ethData;

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
                                                         -- store IP information
  storeInfo: process(reset, clock)
  begin
    if reset = '1' then
      payloadLength <= (others => '0');
      protocol <= (others => '0');
      sourceIpAddr <= (others => '0');
    elsif rising_edge(clock) then
      if addressCounter =  5 then
        payloadLength <= dataShiftRegister(payloadLength'range) - 20;
      end if;
      if addressCounter = 11 then
        protocol <= std_ulogic_vector(dataShiftRegister(protocol'range));
      end if;
      if addressCounter = 17 then
        sourceIpAddr <= std_ulogic_vector(dataShiftRegister);
      end if;
    end if;
  end process storeInfo;

  ------------------------------------------------------------------------------
                                                           -- calculate checksum
  checksumCalcEn <= '1' when
    (unpackState = readHeader) and (addressCounter > 0)
    else '0';

  headerData16 <= resize(dataU, headerData16'length) when addressCounter(0) = '0'
    else shift_left(resize(dataU, headerData16'length), dataU'length);

  calculateChecksum: process(reset, clock)
  begin
    if reset = '1' then
      checksum <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = idle then
        checksum <= (others => '0');
      elsif checksumCalcEn = '1' then
        if checksum(checksum'high) = '1' then
          checksum <= resize(
            checksum(checksum'high-1 downto 0), checksum'length
          ) + headerData16 + 1;
        else
          checksum <= checksum + headerData16;
        end if;
      end if;
    end if;
  end process calculateChecksum;

  checksumInv <= not(checksum(checksumInv'range)) when checksum(checksum'high) = '0'
    else not(checksum(checksumInv'range) + 1);

  ------------------------------------------------------------------------------
                                         -- calculate UDP pseudo-header checksum
  udpChecksumCalcEn <= '1' when
    (unpackState = readHeader) and (
      ( ( 3 <= addressCounter) and (addressCounter <=  4) ) or
      ( addressCounter = 10 ) or
      ( (13 <= addressCounter) and (addressCounter <= 20) )
    )
    else '0';

  calculateUdpChecksum: process(reset, clock)
  begin
    if reset = '1' then
      udpChecksum <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = idle then
        -- start the counter with the difference between IP and UDP lengths
        udpChecksum <= '0' & unsigned(to_signed(-20-1, udpChecksum'length-1));
      elsif udpChecksumCalcEn = '1' then
        if udpChecksum(udpChecksum'high) = '1' then
          udpChecksum <= resize(
            udpChecksum(udpChecksum'high-1 downto 0), udpChecksum'length
          ) + headerData16 + 1;
        else
          udpChecksum <= udpChecksum + headerData16;
        end if;
      end if;
    end if;
  end process calculateUdpChecksum;

  udpPseudoHeaderChecksum <= udpChecksum;

END ARCHITECTURE RTL;
