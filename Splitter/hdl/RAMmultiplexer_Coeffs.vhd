--
-- VHDL Architecture Splitter.RAMmultiplexer.Coeffs
--
-- Created:
--          by - maxim.UNKNOWN (DESKTOP-ADLE19A)
--          at - 15:54:41 19/07/2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE Coeffs OF RAMmultiplexer IS
BEGIN

    writeEnB1 <= writeEnB when enB = '1' else re;
    addressB1 <= addressB when enB = '1' else rdaddr;
    enB1 <= '1';


END ARCHITECTURE Coeffs;

