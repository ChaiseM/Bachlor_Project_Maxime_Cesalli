--
-- VHDL Architecture Splitter.MuxRAM.WithRS232
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 10:21:26 04.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE WithRS232 OF MuxRAM IS

   signal tempData : std_ulogic_vector(dataBitNb-1 downto 0);
   signal tempAddress : std_ulogic_vector(addressBitNb-1 downto 0);
   signal tempWriteEn : std_ulogic;
   
BEGIN
   enB <= '1';
   
   tempData <= dataInB when enB1 = '1' else dataInBRs;
   tempWriteEn <= writeEnB when enB1 = '1' else writeEnRs;
   tempAddress <= addressB when enB1 = '1' else addressBRs;
   
   dataInB1 <= tempData when (enB1 = '1' or outputEn = '1') else dataInB;
   writeEnB1 <= tempWriteEn when (enB1 = '1' or outputEn = '1') else re;
   addressB1 <= tempAddress when (enB1 = '1' or outputEn = '1') else rdaddr;
   
END ARCHITECTURE WithRS232;

