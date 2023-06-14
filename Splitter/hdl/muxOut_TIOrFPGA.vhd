--
-- VHDL Architecture Splitter.muxOut.TIOrFPGA
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 09:58:06 12.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE TIOrFPGA OF muxOut IS
BEGIN


    
    Data_O <= DOUT when S20 = '0' else Data_I ;
    LR_O <= LRCK when S20 = '0' else LR_I ;
    CLK_O <= SCK when S20 = '0' else CLK_I ;


END ARCHITECTURE TIOrFPGA;

