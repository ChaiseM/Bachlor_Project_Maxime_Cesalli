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

    signal oldR : std_ulogic;

BEGIN



    syncro : process(clock,reset)
    begin
        if (reset = '1') then
           oldR <= '0'; 
        elsif rising_edge(clock) then  
            if data_Ready = '0' and oldR = '1' then 
                oldR <= '0';   
                data_SYNC <= data_in;                
            elsif data_Ready = '1' and oldR= '0' then
                oldR <= '1';
                
            end if;
        end if;
    end process syncro;
END ARCHITECTURE leckSync;

