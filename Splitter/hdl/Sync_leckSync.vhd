--
-- VHDL Architecture Splitter.Sync.leckSync
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 10:49:50 06.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE leckSync OF Sync IS

    signal oldLRCK : std_ulogic;

BEGIN



    syncro : process(clock,reset)
    begin
        if (reset = '1') then
           oldLRCK <= '0'; 
        elsif rising_edge(clock) then  
            if lrck = '0' and oldLRCK = '1' then 
                oldLRCK <= '0';   
                data_SYNC <= data_in;                
            elsif lrck = '1' and oldLRCK = '0' then
                oldLRCK <= '1';
                
            end if;
        end if;
    end process syncro;
END ARCHITECTURE leckSync;

