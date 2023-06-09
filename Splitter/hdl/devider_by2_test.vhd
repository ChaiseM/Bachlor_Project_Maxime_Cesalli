--
-- VHDL Architecture Splitter.devider.by2_test
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 15:34:50 02.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ARCHITECTURE by2_test OF devider IS
    
BEGIN

        audioDevided <=  shift_right(audiofull,4);

END ARCHITECTURE by2_test;

