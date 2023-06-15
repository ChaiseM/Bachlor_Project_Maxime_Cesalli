--
-- VHDL Architecture Splitter.eq.With_rot_sw
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 11:31:00 14.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE With_rot_sw OF eq IS
    signal mult :  unsigned(3 downto 0); 
BEGIN
        
        mult(0) <= '1' when b0 = '0' else '0';
        mult(1) <= '1' when b1 = '0' else '0';
        mult(2) <= '1' when b2 = '0' else '0';
        mult(3) <= '1' when b3 = '0' else '0';
        
        audioMod <= resize((shift_right(audioFull,4)*to_integer(mult)),audioMod'length);
    
END ARCHITECTURE With_rot_sw;

