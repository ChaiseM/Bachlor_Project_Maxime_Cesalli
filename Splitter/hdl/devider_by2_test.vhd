--
-- VHDL Architecture Splitter.devider.by2_test
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 15:34:50 02.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE by2_test OF devider IS
BEGIN
    audioDevided <= shift_right(audiofull,1);

END ARCHITECTURE by2_test;

