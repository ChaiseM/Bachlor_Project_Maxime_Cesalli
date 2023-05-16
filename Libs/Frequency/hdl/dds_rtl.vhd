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
-- Direct Digital Synthesizer
--   Generate different waveforms from a step and an enable signal.
--------------------------------------------------------------------------------
-- Author:
--   cof : François Corthay (francois.corthay@hevs.ch)
--   guo : Oliver A. Gubler (oliver.gubler@hevs.ch)
--------------------------------------------------------------------------------
-- Changelog:
--   v2.0 : 2014-03-13 : guo
--     + added triangle output
--   v1.0 : 2013-03-03 : cof
--     * initial version
--------------------------------------------------------------------------------
--
ARCHITECTURE RTL OF dds IS

  signal phase: unsigned(step'range);
  signal triangle_pos: signed(triangle'range);
  signal triangle_off: signed(triangle'range); 

BEGIN

  runFree: process(reset, clock)
  begin
    if reset = '1' then
      phase <= (others => '0');
    elsif rising_edge(clock) then
      if en = '1' then
        phase <= phase + step;
      end if;
    end if;
  end process runFree;

  findCarry: process(en, phase, step)
  begin
    if phase + step < phase then
      carry <= en;
    else
      carry <= '0';
    end if;
  end process findCarry;

  sawtooth <= phase(phase'high downto phase'high-sawtooth'length+1);
  square <= phase(phase'high);
  triangle <= phase(phase'high downto phase'high-triangle'length+1) when phase(phase'high) = '0' else not phase(phase'high downto phase'high-triangle'length+1);

END RTL;
