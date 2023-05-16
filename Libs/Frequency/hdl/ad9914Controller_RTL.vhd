--------------------------------------------------------------------------------
-- Copyright 2014 HES-SO Valais Wallis (www.hevs.ch)
--
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
-- Direct Digital Synthesizer Controler (AD9914)
--   Interface between digital logic or microprocessor and the chip.
--------------------------------------------------------------------------------
-- Author:
--   maf : Fabien Matter (fabien.matter@hevs.ch)
--------------------------------------------------------------------------------
-- Changelog:
--   v1.0 : 2021-11-03 : maf
--     * initial version
--------------------------------------------------------------------------------
--
ARCHITECTURE RTL OF ad9914Controller IS
	
	type portModeType is (parallel, SPI, direct);
	signal portMode: portModeType;
BEGIN
	case portMode is
		when parallel => 
			functions <= ('0','0','0','0');
		when SPI => 
			functions <= ('0','0','0','1');
		when direct => 
			functions <= ('0','0','0','0');
		when others => -- defaults to SPI
			functions<= ('0','0','0','1');
	end case;
	
	
END RTL;
