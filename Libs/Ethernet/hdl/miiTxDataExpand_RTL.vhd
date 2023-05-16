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
--    zas: [Silvan Zahno]
--------------------------------------------------------------------------------
-- Changelog:
--   2016-05-13 : guo : fixed inversed SOF in GigabitEthernet
--   2016-03-31 : guo : fix for verly long frames
--   2016-03 : cof, guo
--      update to be compatible with packets with odd bytecound
--   2015-08 : guo : add startOfFrame, needed by PTP
--   2015-06 : guo
--      update to be compatible with Gigabit Ethernet (miiDataBitNb = 8)
--   2013-08-09 : zas : some changes because of updated requiredBitNb() function
--   2013-02-18 : cof
--      corrected synchronisation in the TX RAM interface
--       (base address remains constant during frame readout)
--------------------------------------------------------------------------------
library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF miiTxDataExpand IS

  constant byteLength_c : positive := 8;
  constant interFrameGapLength_c : positive := 96/miiDataBitNb; -- minimum 96 bit times
  constant crcCount : positive := 4 * byteLength_c/miiDataBitNb;
  constant preambleLength : positive := 8 * byteLength_c/miiDataBitNb;
  signal preambleCounter : unsigned(requiredBitNb(preambleLength)-1 downto 0);
  signal endOfPreambleCount : std_ulogic;
  signal preambleData : std_ulogic_vector(miiData'range);
  signal frameLength, frameCounter : unsigned(readData'range);
  signal ramToMiiCounter : unsigned(counterBitNb(ramDataBitNb/miiDataBitNb)-1 downto 0);
  signal endOfCrc_int : std_ulogic;
  signal interFrameCounter : unsigned(counterBitNb(interframeGapLength_c)-1 downto 0);
  signal txEnable : std_ulogic;
  signal shiftWordData : std_ulogic;
  signal incrRamAddress_int : std_ulogic;
  signal dataShiftRegister : unsigned(readData'range);
  signal loadData : std_ulogic;
  signal miiDataLow, miiDataHigh : std_ulogic_vector(miiData'range);
  signal startOfFrame_int: std_ulogic; 
  signal endOfFrame_int: std_ulogic;
  
BEGIN
  ------------------------------------------------------------------------------
                                  -- Dead time at power-on and end of frame data
  countDeadTime: process(reset, clock)
  begin
    if reset = '1' then
      interFrameCounter <= to_unsigned(interframeGapLength_c-1,interFrameCounter'length);
    elsif rising_edge(clock) then
      if txEnable = '0' then
        interFrameCounter <= interFrameCounter - 1;
      elsif endOfCrc_int = '1' then
        interFrameCounter <= to_unsigned(interframeGapLength_c-1,interFrameCounter'length);
      end if;
    end if;
  end process countDeadTime;

  txEnable <= '1' when interFrameCounter = 0 else '0';

  ------------------------------------------------------------------------------
                                                    -- preamble duration counter
  countPreamble: process(reset, clock)
  begin
    if reset = '1' then
      preambleCounter<= (others => '0');
    elsif rising_edge(clock) then
      if preambleCounter = 0 then
        if sendPreamble = '1' then
          preambleCounter <= preambleCounter + 1;
        end if;
      else
        if endOfPreambleCount = '0' then
          preambleCounter <= preambleCounter + 1;
        else
          preambleCounter<= (others => '0');
        end if;
      end if;
    end if;
  end process countPreamble;

  ------------------------------------------------------------------------------
                                                        -- Frame length register
  storeFramelength: process(reset, clock)
  begin
    if reset = '1' then
      frameLength <= (others => '0');
    elsif rising_edge(clock) then
      if preambleCounter = 1  then
        frameLength <= resize((unsigned(readData(frameLength'high-1 downto 0)))*byteLength_c/miiDataBitNb,frameLength'length);
      end if;
      if endOfCrc_int = '1' then
        frameLength <= (others => '0');
      end if;
    end if;
  end process storeFramelength;

  ------------------------------------------------------------------------------
                                            -- Frame counter and control signals
  countFrame: process(reset, clock)
  begin
    if reset = '1' then
      frameCounter <= (others => '0');
      startOfFrame_int <= '0';
    elsif rising_edge(clock) then
      if endOfPreambleCount = '1'  then
        frameCounter <= to_unsigned(0, frameCounter'length);
        startOfFrame_int <= '1';
      elsif incrMiiAddress = '1' then
        frameCounter <= frameCounter + 1;
        startOfFrame_int <= '0';
      else
        frameCounter <= (others => '0');
        startOfFrame_int <= '0';
      end if;
    end if;
  end process countFrame;

  --TODO: refactor startOfFrame
  startOfFrame <= startOfFrame_int;
  endOfFrame_int <= '1' when frameCounter+1 = frameLength
    else '0';
  endOfFrame <= endOfFrame_int;

  endOfCrc_int <= '1' when frameCounter = frameLength + crcCount - 1
    else '0';
  endOfCrc <= endOfCrc_int;

  frameAvailable <= '1' when 
    (readData(readData'high) = '1') and
    (incrMiiAddress = '0') and 
    (preambleCounter = 0)
    else '0';
  interframeDone <= txEnable;

  ------------------------------------------------------------------------------
                                                -- RAM to MII word width divider
  ramToMiiCounter <= frameCounter(ramToMiiCounter'range);

  incrRamAddress_int <= '1' when
      (preambleCounter = 1) or
      ( (ramToMiiCounter = 0) and (incrMiiAddress='1') and (frameCounter < frameLength))
    else '0';
  incrRamAddress <= incrRamAddress_int;

  ------------------------------------------------------------------------------
                                                          -- Data shift register
  loadData <= '1' when
      (preambleCounter = 4) or
      ( (ramToMiiCounter = (2**ramToMiiCounter'length)-1) and (preambleCounter=0) ) 
    else '0';

  shiftRamData: process(reset, clock)
  begin
    if reset = '1' then
      dataShiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      if loadData = '1' then
        dataShiftRegister <= unsigned(readData);
      elsif shiftWordData = '1' then
        dataShiftRegister <= shift_left(dataShiftRegister, byteLength_c);
      end if;
    end if;
  end process shiftRamData;

  ------------------------------------------------------------------------------
  -- Ethernet or Fast Ethernet (miiDataBitNb = 4)
  ethernetOrFastEthernet: if miiDataBitNb = 4 generate 
    shiftWordData <= incrMiiAddress when (ramToMiiCounter = (2**(ramToMiiCounter'length-1))-1)
      else '0';
    miiDataHigh <= std_ulogic_vector(
      dataShiftRegister(
        dataShiftRegister'high downto
        dataShiftRegister'high - miiData'length + 1
      )
    );
  
    miiDataLow <= std_ulogic_vector(
      dataShiftRegister(
        dataShiftRegister'high - miiData'length downto
        dataShiftRegister'high - miiData'length - miiData'length + 1
      )
    );
    
    miiData <= preambleData when preambleCounter /= 0
      else miiDataLow when ramToMiiCounter(0) = '0' 
      else miiDataHigh;
    endOfPreambleCount <= '1' when preambleCounter = preambleLength
      else '0';
    preambleData <= X"5" when endOfPreambleCount = '0'
      else X"D";
    preambleEnd <= endOfPreambleCount;

    crcData <= miiDataHigh & miiDataLow;
    crcDataValid <= '1' when (ramToMiiCounter(0) = '1')
      else '0';
  end generate;

  ------------------------------------------------------------------------------
  -- Gigabit Ethernet (miiDataBitNb = 8)
  gigabitEthernet: if miiDataBitNb = 8 generate
    -- no shifting
    shiftWordData <= '0';
    miiDataHigh <= std_ulogic_vector(
      readData(
        dataShiftRegister'high downto
        dataShiftRegister'high - miiData'length + 1
      )
    );
  
    miiDataLow <= std_ulogic_vector(
      readData(
        dataShiftRegister'high - miiData'length downto
        dataShiftRegister'high - miiData'length - miiData'length + 1
      )
    );

    miiData <= preambleData when preambleCounter /= 0
      else miiDataHigh when ramToMiiCounter(0) = '0'
      else miiDataLow;
    endOfPreambleCount <= '1' when preambleCounter = preambleLength
      else '0';
    preambleData <= X"55" when endOfPreambleCount = '0'
      else X"D5";
    preambleEnd <= endOfPreambleCount;
    crcData <= 
      miiDataHigh when ramToMiiCounter(0) = '0' 
      else miiDataLow;
    -- dataValid = crc enable: can be always 1, as we never wan't to do comp
    --                         (see crc32_RTL.vhd)
    crcDataValid <= '1';
  end generate;

END ARCHITECTURE RTL;
