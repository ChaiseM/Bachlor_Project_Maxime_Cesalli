--------------------------------------------------------------------------------
-- Copyright 2013 HES-SO Valais Wallis (www.hevs.ch)
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
-- Analog-Digital-Converter PCM1801 controller
--   The PCM1801 is used with the I2S serial interface.
--   Description & Samples: http://www.ti.com/product/pcm1801
--
--   Created on 2021-04-13
--
--   Version: 1.0 Fabien Matter (fabien.matter@hevs.ch)
--------------------------------------------------------------------------------

library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF adc1801Controller IS
									-- SCKI
  signal ddsPhase: unsigned(ddsBitNb-1 downto 0);
                                                           -- serial to parallel
  constant channelNb : positive := 2; 
  subtype sampleRegType is signed(sampleL'range);
  type sampleArrayType is array (1 to channelNb) of sampleRegType;

  signal sckiDelayed : std_ulogic;
  signal sckiRising : std_ulogic;
  signal bckDelayed : std_ulogic;
  signal lrckDelayed : std_ulogic;
  signal bckRising : std_ulogic;
  signal lrckChanged : std_ulogic;
  signal sdIn: std_ulogic_vector(1 to channelNb);
  signal samplesReg, samplesOut : sampleArrayType;
  signal sampleEn_int : std_ulogic;
  constant bckToLrckRatio: unsigned(5 downto 0) := to_unsigned(48/2,6);
  constant sckToBckRatio: unsigned(3 downto 0) := to_unsigned(8/2,4);
  signal sckiCounter: unsigned(2 downto 0); --8 scki per bck
  signal bckCounter: unsigned(5 downto 0);-- 48 bck per lrck;
  signal intBCK: std_ulogic := '0';
  signal intLRCK: std_ulogic := '0';
 
BEGIN
  ------------------------------------------------------------------------------
  -- This setup is :
  --    * I2S serial audio interface format (datasheet fig.25.)
  ------------------------------------------------------------------------------
                                                         -- output bits
                                                
  FMT <= '1';                                           -- HP filter bypass (datasheet p.16)          
  BYPAS <= '1';											-- I2S format (datasheet table 3.)


  ------------------------------------------------------------------------------
                                                                     -- SCKI
  buildDdsSawtooth: process(reset, clock)
  begin
    if reset = '1' then
      ddsPhase <= (others => '0');
    elsif rising_edge(clock) then
      ddsPhase <= ddsPhase + ddsStep;
    end if;
  end process buildDdsSawtooth;
  
  SCKI <= ddsPhase(ddsPhase'high);

  ------------------------------------------------------------------------------
															-- I2S deserializer
process(reset,clock)
  begin
	if reset = '1' then
	  sckiDelayed <= '0';
	  bckDelayed <= '0';
	  lrckDelayed <= '0';
	elsif rising_edge(clock) then
	  sckiDelayed <= SCKI;
	  bckDelayed <= BCK;
	  lrckDelayed <= LRCK;
	end if;
  end process;
  sckiRising <= '1' when (sckiDelayed = '0' and SCKI = '1') else '0';
  bckRising <= '1' when (BCK = '1' and bckDelayed = '0') else '0';
  lrckChanged <= '1' when LRCK /= lrckDelayed else '0';
  
process(reset,clock)
  begin
	if reset = '1' then
	  BCK <= '0';
	  LRCK <= '0';
	  sckiCounter <= (others=>'0');
	  bckCounter <= (others=>'0');
    elsif rising_edge(clock) then
      if sckiRising = '1' then
		  if sckiCounter < sckToBckRatio - 1 then
			sckiCounter <= sckiCounter + 1;
		  else
			sckiCounter <= (others=>'0');
			if BCK = '1' then
			  if bckCounter < bckToLrckRatio - 1 then
				bckCounter <= bckCounter + 1;
			  else
				bckCounter <= (others=>'0');
				LRCK <= not LRCK;
			  end if;
			end if;
			BCK <= not BCK;
		  end if;
      end if;
	end if;
  end process;
  
  sdIn(1) <= DIN;
  sdIn(2) <= DIN;

  shiftRegisters: process(reset, clock)
  begin
    if reset = '1' then
      samplesReg <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if bckRising = '1' then
        if bckCounter < sampleRegType'length+1 and bckCounter > 0 then
          if LRCK = '0' then -- odd channel arrives: 1
            for index in 0 to channelNb/2-1 loop
              samplesReg(2*index+1) <= shift_left(samplesReg(2*index+1), 1);
              samplesReg(2*index+1)(0) <= sdIn(2*index+1);
            end loop;
          else -- even channel arrives: 2
            for index in 1 to channelNb/2 loop
              samplesReg(2*index) <= shift_left(samplesReg(2*index), 1);
              samplesReg(2*index)(0) <= sdIn(2*index);
            end loop;
          end if;
        end if;
      end if;
    end if;
  end process shiftRegisters;

  outputData: process(reset, clock)
  begin
    if reset = '1' then
      samplesOut <= (others => (others => '0'));
      sampleEn_int <= '0';
    elsif rising_edge(clock) then
      if (lrckChanged = '1') and (LRCK = '1') then
		sampleEn_int <= '1';
        for index in samplesOut'range loop
          samplesOut(index) <= shift_left(
            samplesReg(index) + inputOffset,
            inputShiftBitNb
          );
        end loop;
      else
        sampleEn_int <= '0';
      end if;
    end if;
  end process outputData;

  ------------------------------------------------------------------------------
                                                                      -- Outputs
  sampleEn <= sampleEn_int;
  sampleL <= samplesOut(1);
  sampleR <= samplesOut(2);

END ARCHITECTURE RTL;
