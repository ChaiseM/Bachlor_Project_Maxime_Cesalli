--
-- VHDL Architecture Splitter.testerRS232.RS232_test1
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 09:43:22 02.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE RS232_test1 OF testerRS232 IS
BEGIN
   
   testter : process(RS232Valid,RS232Data)
   begin 
      debug <= '0';
      if RS232Valid = '1' then 
         if unsigned(RS232Data) = 53 then 
            debug <= '1';
         end if;
      end if;
   end process testter;

END ARCHITECTURE RS232_test1;

