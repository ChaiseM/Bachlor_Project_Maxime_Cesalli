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
-- -----------------------------------------------------------------------------
-- miiSender test
--   
-- -----------------------------------------------------------------------------
--  Authors: 
--    cof: [François Corthay](francois.corthay@hevs.ch)
--    guo: [Oliver A. Gubler](oliver.gubler@hevs.ch)
--    zas: [Silvan Zahno]
-- -----------------------------------------------------------------------------
-- Changelog:
--   2016-02 : cof
--     rewrite to specify frame byte length
--   2015-06 : guo
--     update to be compatible with Gigabit Ethernet (miiDataBitNb = 8)
--   2012-06-19 : zas
-- -----------------------------------------------------------------------------
LIBRARY Common;
USE Common.CommonLib.all;

ARCHITECTURE RTL OF miiRxWriteCounter IS

  constant crcLength: positive := 4;
  constant bytesPerWord: positive := ramDataBitNb/8;
  constant byteCounterAdditionalBitNb: positive := requiredBitNb(bytesPerWord-1);
  constant byteCounterBitNb: positive := writeAddress'length + byteCounterAdditionalBitNb;
  signal byteCounter : unsigned(byteCounterBitNb-1 downto 0);
  signal writeWordEn1, writeWordEn, writeWord : std_ulogic;

  signal addressFromCounter : unsigned(writeAddress'range);
  signal baseAddress, nextBaseAddress : unsigned(writeAddress'range);
  signal frameLength_int : unsigned(frameLength'range);

BEGIN

  ------------------------------------------------------------------------------
  -- The byte counter increments during frame reception, when a new byte has
  -- been received.
  -- As the memory width is larger than one byte, the address counter
  -- corresponds to the MSBs of the byte counter.
  -- At the end of the frame, when frameOk is asserted, the base address has
  -- to be provided, together with the frame length to be written in the RAM.
  -- After power-up, a write command at address zero must clear the
  -- frame data available bit: this is done as long as initFrame is '1'
  -- initFrame is also activated at the end of each received frame
  -- in order to zero the frame data available bit of the next frame.

  ------------------------------------------------------------------------------
                                                                 -- byte counter
  countBytes: process(reset, clock)
  begin
    if reset = '1' then
      -- start with frameLength = -2**byteCounterAdditionalBitNb
      -- so that the very first nextBaseAddress = 0
      byteCounter <=
        to_unsigned(crcLength, byteCounter'length) -
        to_unsigned(2**byteCounterAdditionalBitNb, byteCounter'length);
    elsif rising_edge(clock) then
      if startOfFrame = '1' then
        byteCounter <= to_unsigned(0, byteCounter'length);
      elsif (incrAddress = '1') and (byteEn = '1') then
        byteCounter <= byteCounter + 1;
      elsif frameError = '1' then
        byteCounter <= to_unsigned(2*bytesPerWord, byteCounter'length);
      end if;
    end if;
  end process countBytes;
                                                              -- address pointer
  addressFromCounter <= resize(
    shift_right(byteCounter, byteCounterAdditionalBitNb),
    addressFromCounter'length
  );
                                                                -- write control
  toggleWriteEnable: process(reset, clock)
  begin
    if reset = '1' then
      writeWordEn <= '0';
      writeWordEn1 <= '0';
    elsif rising_edge(clock) then
      writeWordEn1 <= '0';
      if startOfFrame = '1' then
        writeWordEn1 <= '1';
      elsif writeWordEn1 = '1' then
        writeWordEn <= '1';
      elsif initFrame = '1' then
        writeWordEn <= '0';
      end if;
    end if;
  end process toggleWriteEnable;

--  writeWordEn <= incrAddress and incrAddressDelayed and byteEn;
  writeWord <= (writeWordEn and byteEn) when byteCounter(byteCounterAdditionalBitNb-1 downto 0) = 0
    else '0';
  writeEn <= initFrame or writeWord or frameOk or frameError;

  ------------------------------------------------------------------------------
                                              -- frame length and base addresses
  frameLength_int <= resize(byteCounter-crcLength, frameLength'length);
  nextBaseAddress <=
    resize(
      shift_right(frameLength_int + 1, byteCounterAdditionalBitNb),
      nextBaseAddress'length
    ) + baseAddress + 1;
  frameLength <= frameLength_int;

  storeFrameBaseAddress: process(reset, clock)
  begin
    if reset = '1' then
      baseAddress <= (others => '0');
    elsif rising_edge(clock) then
      if startOfFrame = '1' then
        baseAddress <= nextBaseAddress;
      end if;
    end if;
  end process storeFrameBaseAddress;

  ------------------------------------------------------------------------------
                                                  -- RAM write address selection
  writeAddress <=
    nextBaseAddress        when (initFrame = '1') and (frameError = '0') else
    baseAddress + 1        when (initFrame = '1') and (frameError = '1') else
    baseAddress            when (initFrame = '0') and (frameError = '1') else
    baseAddress            when frameOk = '1'                            else
    baseAddress + addressFromCounter;

END ARCHITECTURE RTL;
