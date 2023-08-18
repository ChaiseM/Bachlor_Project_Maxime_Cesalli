--
-- VHDL Architecture Splitter.LefrRightSelector.archi1
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 13:33:00 15.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE archi1 OF LefrRightSelector IS
BEGIN
   audio_In <= audio_L_out when S21 = '0' else audio_R_out;
END ARCHITECTURE archi1;

