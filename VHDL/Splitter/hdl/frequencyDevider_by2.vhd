--
-- VHDL Architecture Splitter.frequencyDevider.by2
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 14:15:18 12.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE by2 OF frequencyDevider IS
   
    signal old_enabler  : std_ulogic;
BEGIN

    devider : process(clock,reset)
     variable enabler : std_ulogic := '0';
    begin 
       if reset = '1' then
		enabler := '0';	
		elsif rising_edge(clock) then
        
            enDiv <= '0';
            if en = '1' then 
                enabler := not enabler;
            end if;
            
            if enabler = '0' and  old_enabler = '1' then 
                enDiv <= '1';
                old_enabler <= '0';
            elsif enabler = '1' and  old_enabler = '0' then
                old_enabler <= '1';
            end if;
            
        end if;
    end process devider;

    


END ARCHITECTURE by2;

