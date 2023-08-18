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
-- ethernet package
--
-- -----------------------------------------------------------------------------
--  Authors:
--    cof: [François Corthay](francois.corthay@hevs.ch)
--    guo: [Oliver A. Gubler](oliver.gubler@hevs.ch)
--    zas: [Silvan Zahno]
-- -----------------------------------------------------------------------------
-- Changelog:
--   2015-06 : guo
--     added defines for ethernet types
--   2012-05-12 : zas
-- -----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE ethernet IS

-- Registers Used in the UDP application
constant CFG_reg_AddrBitNb             : positive := 8;
constant CFG_reg_DataBitNb             : positive := 32;
type reg_type is array (natural range <>) of std_ulogic_vector(CFG_reg_DataBitNb-1 downto 0);

-- Defines for MII of different ethernet types
type ethernet_type is record
	miiDataBitNb : integer range 4 to 8;
	miiClockFreq : integer range 2500E3 to 125E6;
end record;
constant Ethernet         : ethernet_type := (4,  2500E3);  --   10BaseT
constant FastEthernet     : ethernet_type := (4, 25E6);     --  100BaseT
constant GigabitEthernet  : ethernet_type := (8,125E6);     -- 1000BaseT

END ethernet;
