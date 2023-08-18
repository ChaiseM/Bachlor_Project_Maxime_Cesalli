--------------------------------------------------------------------------------
-- Copyright 2012 HES-SO Valais Wallis (www.hevs.ch)
--------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program IS distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License along with
-- this program. If not, see <http://www.gnu.org/licenses/>
--------------------------------------------------------------------------------
-- miiTxDataExpand
--   Expand the data from memory to MII bus width
--------------------------------------------------------------------------------
--  Authors: 
--    cof: [François Corthay](francois.corthay@hevs.ch)
--    guo: [Oliver A. Gubler](oliver.gubler@hevs.ch)
--------------------------------------------------------------------------------
-- Changelog:
--   2015-08 : guo
--      add destUdpPortValid, needed by PTP
--   2013-02 : cof
--------------------------------------------------------------------------------
ARCHITECTURE RTL OF udpPack IS

  type packStateType is (
    idle, waitReady,
    writeHeader, transparent,
    writeLength, writeChecksum,
    endOfFrame
  );
  signal packState: packStateType;

  signal sourceUdpPortU: unsigned(sourceUdpPort'range);
  signal destUdpPortU: unsigned(destUdpPort'range);

  signal addressCounter: unsigned(ipAddress'range);
  signal headerData: unsigned(ipData'range);
  signal totalLength: unsigned(15 downto 0);
  signal checksumCalcEn: std_ulogic;
  signal length2: unsigned(totalLength'range);
  signal checksumData: unsigned(udpData'range);
  signal checksumData16: unsigned(15 downto 0);
  signal checksum: unsigned(15+1 downto 0);
  signal checksumInv: unsigned(15 downto 0);

BEGIN

  sourceUdpPortU <= unsigned(sourceUdpPort);
  destUdpPortU <= unsigned(destUdpPort);

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  packFsm: process(reset, clock)
  begin
    if reset = '1' then
      packState <= idle;
    elsif rising_edge(clock) then
      case packState is
        when idle =>
          if sendUdpFrame = '1' then
            packState <= waitReady;
          end if;
        when waitReady =>
          if ipReady = '1' then
            packState <= writeHeader;
          end if;
        when writeHeader =>
          if addressCounter >= 3 then
            packState <= transparent;
          end if;
        when transparent =>
          if sendUdpFrame = '0' then
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
    udpAddress, udpData, udpWrite
  )
  begin
    sendIpFrame <= '0';
    ipAddress <= (others => '-');
    ipData <= (others => '-');
    ipWrite <= '0';
    udpReady <= '0';
    case packState is
      when waitReady =>
        sendIpFrame <= '1';
      when writeHeader | writeLength | writeChecksum =>
        sendIpFrame <= '1';
        ipWrite <= '1';
        ipAddress <= addressCounter;
        ipData <= std_ulogic_vector(headerData);
      when transparent =>
        udpReady <= '1';
        sendIpFrame <= '1';
        ipWrite <= udpWrite;
        ipAddress <= udpAddress + 8;
        ipData <= udpData;
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
      if packState = idle then
        if sendUdpFrame = '0' then
          addressCounter <= (others => '0');
        else
          addressCounter <= to_unsigned(8, addressCounter'length);
        end if;
      elsif packState = waitReady then
        if ipReady = '0' then
          addressCounter <= addressCounter + 1;
        else
          addressCounter <= (others => '0');
        end if;
      elsif packState = transparent then
        if sendUdpFrame = '1' then
          if udpWrite = '1' then
            addressCounter <= addressCounter + 1;
          end if;
        else
          addressCounter <= to_unsigned(4, addressCounter'length);
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
    sourceUdpPortU, 
    destUdpPortU, 
    totalLength, 
    checksumInv, 
    sourceIpAddr, 
    destIpAddr
  )
  begin
    destUdpPortValid <= '0';
    case to_integer(addressCounter) is
      -- source port number
      when  0 => headerData <= resize(shift_right(sourceUdpPortU, headerData'length), headerData'length);
      when  1 => headerData <= resize(sourceUdpPortU, headerData'length);
      -- destination port number
      when  2 => headerData <= resize(shift_right(destUdpPortU, headerData'length), headerData'length);
      when  3 => headerData <= resize(destUdpPortU, headerData'length);
                 destUdpPortValid <= '1';
      -- total length
      when  4 => headerData <= resize(shift_right(totalLength, headerData'length), headerData'length);
      when  5 => headerData <= resize(totalLength, headerData'length);
      -- checksum
      when  6 => headerData <= resize(shift_right(checksumInv, headerData'length), headerData'length);
      when  7 => headerData <= resize(checksumInv, headerData'length);
      -- source IP address
      when  8 => headerData <= resize(shift_right(unsigned(sourceIpAddr), 3*headerData'length), headerData'length);
      when  9 => headerData <= resize(shift_right(unsigned(sourceIpAddr), 2*headerData'length), headerData'length);
      when 10 => headerData <= resize(shift_right(unsigned(sourceIpAddr), headerData'length), headerData'length);
      when 11 => headerData <= resize(unsigned(sourceIpAddr), headerData'length);
      -- destination IP address
      when 12 => headerData <= resize(shift_right(unsigned(destIpAddr), 3*headerData'length), headerData'length);
      when 13 => headerData <= resize(shift_right(unsigned(destIpAddr), 2*headerData'length), headerData'length);
      when 14 => headerData <= resize(shift_right(unsigned(destIpAddr), headerData'length), headerData'length);
      when 15 => headerData <= resize(unsigned(destIpAddr), headerData'length);
      -- zeros
      when 16 => headerData <= to_unsigned(16#00#, headerData'length);
      -- IP protocol
      when 17 => headerData <= to_unsigned(16#11#, headerData'length);
      when others => headerData <= (others => '-');
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
        totalLength <= to_unsigned(8, totalLength'length);
      elsif packState = transparent then
        if udpWrite = '1' then
          totalLength <= totalLength + 1;
        end if;
      end if;
    end if;
  end process countFrameLength;

  ------------------------------------------------------------------------------
                                                                -- calculate CRC
  checksumCalcEn <= '1' when
    ( (packState = waitReady) and (addressCounter <= 17 ) ) or
      (packState = writeHeader) or
    ( (packState = transparent) and (udpWrite = '1') ) or
      (packState = writeLength)
    else '0';

  length2 <= shift_left(totalLength, 1) when totalLength(totalLength'high) = '0'
    else shift_left(totalLength, 1) + 1;

  checksumData <= unsigned(udpData)
      when packState = transparent
    else resize(shift_right(length2, checksumData'length), checksumData'length)
      when (packState = writeLength) and (addressCounter(0) = '0')
    else resize(length2, checksumData'length)
      when (packState = writeLength) and (addressCounter(0) = '1')
    else headerData;

  checksumData16 <= resize(checksumData , checksumData16'length)
      when addressCounter(0) = '1'
    else shift_left(resize(checksumData , checksumData16'length), checksumData 'length);

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
          ) + checksumData16 + 1;
        else
          checksum <= checksum + checksumData16;
        end if;
      end if;
    end if;
  end process calculateChecksum;

  checksumInv <= (others => '1') when signed(checksum) = -1
    else not(checksum(checksumInv'range)) when checksum(checksum'high) = '0'
    else not(checksum(checksumInv'range) + 1);

END ARCHITECTURE RTL;