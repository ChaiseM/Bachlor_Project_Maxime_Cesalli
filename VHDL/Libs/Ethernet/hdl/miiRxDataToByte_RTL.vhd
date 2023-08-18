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
-- miiRxDataToByte
--
-- -----------------------------------------------------------------------------
--  Authors:
--    cof: [François Corthay](francois.corthay@hevs.ch)
--    guo: [Oliver A. Gubler](oliver.gubler@hevs.ch)
--    zas: [Silvan Zahno]
-- -----------------------------------------------------------------------------
-- Changelog:
--   v1.0 : 2012-06-12 : zas
-- -----------------------------------------------------------------------------
ARCHITECTURE RTL OF miiRxDataToByte IS

  signal dataNibble       : std_ulogic_vector(miiData'range);
  signal dataNibbleStored : std_ulogic_vector(miiData'range);

  signal storeLsb : std_ulogic;

BEGIN

  dataNibble <= miiData;

  storeNibble: process(reset, clock)
  begin
    if reset = '1' then
      dataNibbleStored <= (others => '0');
    elsif rising_edge(clock) then
      dataNibbleStored <= dataNibble;
    end if;
  end process storeNibble;

  miiByte <= dataNibble & dataNibbleStored;

  divideShiftControl: process(reset, clock)
  begin
    if reset = '1' then
      storeLsb <= '0';
    elsif rising_edge(clock) then
      if startOfFrame = '1' then
        storeLsb <= '1';
      else
        storeLsb <= not storeLsb;
      end if;
    end if;
  end process divideShiftControl;

  byteEn <= storeLsb and not startOfFrame;

END ARCHITECTURE RTL;
