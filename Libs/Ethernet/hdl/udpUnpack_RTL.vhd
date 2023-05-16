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
ARCHITECTURE RTL OF udpUnpack IS

  type unpackStateType is (idle, readHeader, transparent, endOfFrame, checksumError);
  signal unpackState: unpackStateType;
  signal readHeaderEnd: std_ulogic;
  signal readHeaderEnd1, readHeaderEnd2: std_ulogic;

  signal addressCounter: unsigned(ipAddress'range);
  signal addressStep: unsigned(ipAddress'range);
  signal dataU: unsigned(ipData'range);
  signal dataShiftRegister: unsigned(destUdpPort'range);

  signal checksumCalcEn: std_ulogic;
  signal headerData16: unsigned(15 downto 0);
  signal headerDataByteSelect: std_ulogic;
  signal checksum: unsigned(15+1 downto 0);
  signal checksumInv: unsigned(15 downto 0);

BEGIN

  dataU <= unsigned(ipData);

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  readHeaderEnd <= '1' when (unpackState = readHeader) and (addressCounter >= 7)
    else '0';

  delayReadHeaderEnd: process(reset, clock)
  begin
    if reset = '1' then
      readHeaderEnd1 <= '0';
      readHeaderEnd2 <= '0';
    elsif rising_edge(clock) then
      readHeaderEnd1 <= readHeaderEnd;
      readHeaderEnd2 <= readHeaderEnd1;
    end if;
  end process delayReadHeaderEnd;

  unpackFsm: process(reset, clock)
  begin
    if reset = '1' then
      unpackState <= idle;
      destUdpPort <= (others => '0');
      destUdpPortValid <= '0';
    elsif rising_edge(clock) then
      destUdpPortValid <= '0';
      case unpackState is
        when idle =>
          if (enUdp = '1') and (newIpFrame = '1') then
            unpackState <= readHeader;
          end if;
        when readHeader =>
          if addressCounter = 5 then
            destUdpPort <= std_ulogic_vector(dataShiftRegister);
            destUdpPortValid <= '1';
          elsif readHeaderEnd = '1' then
            unpackState <= transparent;
          end if;
        when transparent =>
          if udpDone = '1' then
            unpackState <= endOfFrame;
          end if;
        when endOfFrame =>
          if checksumInv = 0 then
            unpackState <= idle;
          else
            unpackState <= checksumError;
          end if;
        when checksumError =>
          unpackState <= idle;
      end case;
    end if;
  end process unpackFsm;

  unpackControls: process(
    unpackState,
    addressCounter, udpAddress,
    checksumInv
  )
  begin
    ipAddress <= addressCounter;
    addressStep <= to_unsigned(0, addressStep'length);
    newUdpFrame <= '0';
    ipDone <= '0';
    udpChecksumError <= '0';
    case unpackState is
      when readHeader =>
        addressStep <= to_unsigned(1, addressStep'length);
      when transparent =>
        newUdpFrame <= '1';
        ipAddress <= udpAddress;
      when endOfFrame =>
        ipDone <= '1';
        if checksumInv /= 0 then
          udpChecksumError <= '1';
        end if;
      when checksumError =>
        udpChecksumError <= '1';
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
  udpData <= ipData;

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
                                                        -- store UDP information
  storeInfo: process(reset, clock)
  begin
    if reset = '1' then
      payloadLength <= (others => '0');
      sourceUdpPort <= (others => '0');
    elsif rising_edge(clock) then
      if addressCounter = 3 then
        sourceUdpPort <= std_ulogic_vector(dataShiftRegister);
      end if;
      if addressCounter =  7 then
        payloadLength <= dataShiftRegister(payloadLength'range) - 8;
      end if;
    end if;
  end process storeInfo;

  ------------------------------------------------------------------------------
                                                           -- calculate checksum
  checksumCalcEn <= '1' when
    ( (unpackState = readHeader) and (addressCounter > 0) ) or
    ( (unpackState = transparent) and (readHeaderEnd2 = '0') and (udpRead = '1') )
    else '0';

  headerDataByteSelect <= udpAddress(0)
    when (unpackState = transparent) and (readHeaderEnd1 = '0')
    else addressCounter(0);

  headerData16 <= resize(dataU, headerData16'length) when headerDataByteSelect = '0'
    else shift_left(resize(dataU, headerData16'length), dataU'length);

  calculateChecksum: process(reset, clock)
  begin
    if reset = '1' then
      checksum <= (others => '0');
    elsif rising_edge(clock) then
      if unpackState = idle then
        checksum <= pseudoHeaderChecksum;
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