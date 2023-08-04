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
BEGIN
   enB <= '1';
   mux : process 
   begin 
      if enB1 = '1' then 
         dataInB1 <= dataInB;
         writeEnB1 <= writeEnB;
         addressB1 <= addressB;
      elsif outputEn = '1' then 
         dataInB1 <= dataInBRs;
         writeEnB1 <= writeEnRs;
         addressB1 <= addressBRs;
      else 
         dataInB1 <= dataInB;
         writeEnB1 <= re;
         addressB1 <= rdaddr;
      end if;
   end process mux;
END ARCHITECTURE WithRS232;

