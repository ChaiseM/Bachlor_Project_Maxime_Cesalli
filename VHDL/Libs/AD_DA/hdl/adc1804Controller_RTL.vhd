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
-- Analog-Digital-Converter PCM1804 controller
--   The PCM1804 is used in master mode with the I2S serial interface.
--   Description & Samples: http://www.ti.com/product/pcm1804
--
--   Created on 2013-09-25
--
--   Version: 1.0 Oliver A. Gubler (oliver.gubler@hevs.ch)
--   Version: 1.1 Francois Corthay (francois.corthay@hevs.ch)
--------------------------------------------------------------------------------

library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF adc1804Controller IS
                                                                        -- reset
  constant resetPulseWidth: real := 40.0E-9;
  constant resetCounterLength: positive := integer(resetPulseWidth*clockFrequency) + 1;
  constant resetCounterBitNb: positive := requiredBitNb(resetCounterLength);
  signal resetCounter: unsigned(resetCounterBitNb-1 DOWNTO 0);
  signal resetCounterDone: std_ulogic;
                                                                         -- SCKI
  signal ddsPhase: unsigned(ddsBitNb-1 downto 0);
                                                           -- serial to parallel
  constant channelNb : positive := 2; 
  subtype sampleRegType is signed(sampleL'range);
  type sampleArrayType is array (1 to channelNb) of sampleRegType;

  signal bck_delayed : std_ulogic;
  signal lrck_delayed : std_ulogic;
  signal bck_rising : std_ulogic;
  signal lrck_changed : std_ulogic;
  signal bitCounter : unsigned(4 downto 0);  -- count to 32
  signal sdIn: std_ulogic_vector(1 to channelNb);
  signal samplesReg, samplesOut : sampleArrayType;
  signal sampleEn_int : std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
  -- This setup is for master mode with:
  --    * I2S serial audio interface format (datasheet fig.36)
  --    * quad rate oversampling
  ------------------------------------------------------------------------------
                                                         -- slave or master mode
  S_M <= '0';
                                                -- I2S format (datasheet fig.36)
  FMT <= "01";
                                      -- oversampling (datasheet tables 1 and 3)
  OSR <= "110";
                                                                  -- output bits
  BYPAS <= '1';

  ------------------------------------------------------------------------------
                                                                    -- ADC reset
  countResetDuration: process(clock, reset)
  begin
    if reset = '1' then
      resetCounter <= (others => '0');
    elsif rising_edge(clock) then
      if resetCounterDone = '0' then
        resetCounter <= resetCounter + 1;
      end if;
    end if;
  end process countResetDuration;

  resetCounterDone <= '1' when resetCounter = resetCounterLength
    else '0';

  RST_n <= not '0' when resetCounterDone = '1'
    else not '1';

  ------------------------------------------------------------------------------
                                                                     -- SCKI DDS
  buildDdsSawtooth: process(reset, clock)
  begin
    if reset = '1' then
      ddsPhase <= (others => '0');
    elsif rising_edge(clock) then
      ddsPhase <= ddsPhase + ddsStep;
    end if;
  end process buildDdsSawtooth;

  SCKI <= ddsPhase(ddsPhase'high);
  BCK_DSDL <= 'Z';
  LRCK_DSDBCK <= 'Z';

  ------------------------------------------------------------------------------
                                                             -- I2S deserializer
  delayClocks: process(reset, clock)
  begin
    if reset = '1' then
      bck_delayed <= '0';
      lrck_delayed <= '0';
    elsif rising_edge(clock) then
      bck_delayed <= BCK_DSDL;
      lrck_delayed <= LRCK_DSDBCK;
    end if;
  end process delayClocks;

  bck_rising <= '1' when (BCK_DSDL = '1') and (bck_delayed = '0') else '0';
  lrck_changed <= '1' when lrck_delayed /= LRCK_DSDBCK else '0';

  countBits: process(reset, clock)
  begin
    if reset = '1' then
      bitCounter <= (others => '0');
    elsif rising_edge(clock) then
      if lrck_changed = '1' then
        bitCounter <= (others => '0');
      elsif bck_rising = '1' then 
        bitCounter <= bitCounter + 1;
      end if;
    end if;
  end process countBits;

  sdIn(1) <= DATA_DSDR;
  sdIn(2) <= DATA_DSDR;

  shiftRegisters: process(reset, clock)
  begin
    if reset = '1' then
      samplesReg <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if bck_rising = '1' then
        if bitCounter < sampleRegType'length+1 and bitCounter > 0 then
          if LRCK_DSDBCK = '0' then -- odd channel arrives: 1
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
      if (lrck_changed = '1') and (LRCK_DSDBCK = '0') then
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
