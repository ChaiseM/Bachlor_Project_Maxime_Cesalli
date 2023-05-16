ARCHITECTURE RTL OF ipPack IS

  type packStateType is (
    idle, waitReady,
    writeHeader, transparent,
    writeLength, writeChecksum,
    endOfFrame
  );
  signal packState: packStateType;

  signal addressCounter: unsigned(ethAddress'range);
  signal headerData: unsigned(ethData'range);
  signal totalLength: unsigned(15 downto 0);
  signal checksumCalcEn: std_ulogic;
  signal headerData16: unsigned(15 downto 0);
  signal checksum: unsigned(15+1 downto 0);
  signal checksumInv: unsigned(15 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                                    -- sequencer
  packFsm: process(reset, clock)
  begin
    if reset = '1' then
      packState <= idle;
    elsif rising_edge(clock) then
      case packState is
        when idle =>
          if sendIpFrame = '1' then
            packState <= waitReady;
          end if;
        when waitReady =>
          if ethReady = '1' then
            packState <= writeHeader;
          end if;
        when writeHeader =>
          if addressCounter >= 19 then
            packState <= transparent;
          end if;
        when transparent =>
          if sendIpFrame = '0' then
            packState <= writeLength;
          end if;
        when writeLength =>
          if addressCounter(0) = '1' then
            packState <= writeChecksum;
          end if;
        when writeChecksum =>
          if addressCounter(0) = '1' then
            packState <= endOfFrame;
          end if;
        when endOfFrame =>
          packState <= idle;
      end case;
    end if;
  end process packFsm;

  packControls: process(
    packState,
    addressCounter, headerData,
    ipAddress, ipData, ipWrite
  )
  begin
    sendEthFrame <= '0';
    ethAddress <= (others => '-');
    ethData <= (others => '-');
    ethWrite <= '0';
    ipReady <= '0';
    case packState is
      when waitReady =>
        sendEthFrame <= '1';
      when writeHeader | writeLength | writeChecksum =>
        sendEthFrame <= '1';
        ethWrite <= '1';
        ethAddress <= addressCounter;
        ethData <= std_ulogic_vector(headerData);
      when transparent =>
        ipReady <= '1';
        sendEthFrame <= '1';
        ethWrite <= ipWrite;
        ethAddress <= ipAddress + 20;
        ethData <= ipData;
      when others => null;
    end case;
  end process packControls;

  ------------------------------------------------------------------------------
                                                              -- address counter
  incrementAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressCounter <= (others => '0');
    elsif rising_edge(clock) then
      if (packState = idle) or (packState = waitReady) then
        addressCounter <= (others => '0');
      elsif packState = transparent then
        if sendIpFrame = '1' then
          if ipWrite = '1' then
            addressCounter <= addressCounter + 1;
          end if;
        else
          addressCounter <= to_unsigned(2, addressCounter'length);
        end if;
      elsif packState = writeLength then
        if addressCounter(0) = '0' then
          addressCounter <= addressCounter + 1;
        else
          addressCounter <= to_unsigned(10, addressCounter'length);
        end if;
      else
        addressCounter <= addressCounter + 1;
      end if;
    end if;
  end process incrementAddress;

  ------------------------------------------------------------------------------
                                                            -- build header data
  buildHeaderData: process(
    addressCounter,
    totalLength,
    protocol,
    checksumInv,
    sourceIpAddr,
    destIpAddr
  )
  begin
    case to_integer(addressCounter) is
      -- version
      when  0       => headerData <= to_unsigned(16#45#, headerData'length);
      -- differentiated services ...
      when  1       => headerData <= to_unsigned(0, headerData'length);
      -- total length
      when  2       => headerData <= resize(shift_right(totalLength, headerData'length), headerData'length);
      when  3       => headerData <= resize(totalLength, headerData'length);
      -- identification
      when  4 to  5 => headerData <= to_unsigned(0, headerData'length);
      -- flags
      when  6       => headerData <= to_unsigned(16#40#, headerData'length);
      -- fragment offset
      when  7       => headerData <= to_unsigned(0, headerData'length);
      -- time to live
      when  8       => headerData <= to_unsigned(16#10#, headerData'length);
      -- protocol
      when  9       => headerData <= unsigned(protocol);
      -- header checksum
      when 10       => headerData <= resize(shift_right(checksumInv, headerData'length), headerData'length);
      when 11       => headerData <= resize(checksumInv, headerData'length);
      -- source IP address
      when 12       => headerData <= resize(shift_right(unsigned(sourceIpAddr), 3*headerData'length), headerData'length);
      when 13       => headerData <= resize(shift_right(unsigned(sourceIpAddr), 2*headerData'length), headerData'length);
      when 14       => headerData <= resize(shift_right(unsigned(sourceIpAddr), headerData'length), headerData'length);
      when 15       => headerData <= resize(unsigned(sourceIpAddr), headerData'length);
      -- destination IP address
      when 16       => headerData <= resize(shift_right(unsigned(destIpAddr), 3*headerData'length), headerData'length);
      when 17       => headerData <= resize(shift_right(unsigned(destIpAddr), 2*headerData'length), headerData'length);
      when 18       => headerData <= resize(shift_right(unsigned(destIpAddr), headerData'length), headerData'length);
      when 19       => headerData <= resize(unsigned(destIpAddr), headerData'length);
      when others   => headerData <= (others => '-');
    end case;
  end process buildHeaderData;

  ------------------------------------------------------------------------------
                                                                 -- frame length
  countFrameLength: process(reset, clock)
  begin
    if reset = '1' then
      totalLength <= (others => '0');
    elsif rising_edge(clock) then
      if packState = idle then
        totalLength <= (others => '0');
      elsif packState = writeHeader then
        if addressCounter = 4 then
          totalLength <= to_unsigned(20, totalLength'length);
        end if;
      elsif packState = transparent then
        if ipWrite = '1' then
          totalLength <= totalLength + 1;
        end if;
      end if;
    end if;
  end process countFrameLength;

  ------------------------------------------------------------------------------
                                                                -- calculate CRC
  checksumCalcEn <= '1' when
    ( (packState = writeHeader) and ( (addressCounter < 10) or (11 < addressCounter) ) ) or
      (packState = writeLength)
    else '0';

  headerData16 <= resize(headerData, headerData16'length) when addressCounter(0) = '1'
    else shift_left(resize(headerData, headerData16'length), headerData'length);

  calculateChecksum: process(reset, clock)
  begin
    if reset = '1' then
      checksum <= (others => '0');
    elsif rising_edge(clock) then
      if packState = idle then
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

END ARCHITECTURE RTL;
