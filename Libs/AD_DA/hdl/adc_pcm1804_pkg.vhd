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
-- Analog-Digital-Converter PCM1804 controller package
--   The PCM1804 is used in master mode with the I2S serial interface.
--   Description & Samples: http://www.ti.com/product/pcm1804
--
--   Created on 2013-09-25
--
--   Version: 0.0 incomplete release
--   Author: Oliver A. Gubler (oliver.gubler@hevs.ch)
--------------------------------------------------------------------------------

--!! WARNING: This IP is neither complete nor verified and due to change soon
--!!          and often.

LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
  
library common;
  use common.CommonLib.all;
    
PACKAGE adc_pcm1804 IS
  
  -- data format
  ------------------------------------------------------------------------------
  -- values have to be chosen in accordance to datasheet p. 19
  -- 00 = PCM, left-justified; 01 = PCM, I2S; 10 = PCM, standard; 11 = DSD
  constant adc_pcm1804_fmt: std_ulogic_vector(1 downto 0):= "01";

  -- sampling
  ------------------------------------------------------------------------------
  -- Oversampling Ration in Master Mode
  -- values have to be chosen in accordance to datasheet p. 19
  -- 110 = quad rate x 32fs, 192 fs; 111 = quad rate x 32fs, 128 fs;
  constant adc_pcm1804_osr: std_ulogic_vector(2 downto 0) := "111";

  type     switch_t is array (0 to 7) of integer; 
  constant switch : switch_t := ( 0 => 768, 
                                  1 => 512,
                                  2 => 384,
                                  3 => 256,
                                  4 => 384,
                                  5 => 256,
                                  6 => 192,
                                  7 => 128); 
  constant adc_pcm1804_system_clock_rate : integer:= 
    switch(to_integer(unsigned(adc_pcm1804_osr)));
 
  -- HPF bypass
  ------------------------------------------------------------------------------
  constant adc_pcm1804_bypass: std_ulogic := '1';

  -- timings
  ------------------------------------------------------------------------------
  -- wait time in number of system clocks before setting /RST to high
  constant adc_pcm1804_reset_timeout: positive:= 3;
  -- wait time in number of system clocks until digital output valid after reset
  constant adc_pcm1804_valid_timeout: positive:= 
    1024+1117*adc_pcm1804_system_clock_rate;
  -- reset counter bit number
  constant adc_pcm1804_reset_cnt_bitnumber: positive:= 
    requiredBitNb(adc_pcm1804_valid_timeout);
      
  -- I2S
  ------------------------------------------------------------------------------
  constant adc_pcm1804_resolution: positive := 24;
  constant adc_pcm1804_bit_cnt_bitnumber: positive:= 
    requiredBitNb(adc_pcm1804_resolution);
     
END adc_pcm1804;
