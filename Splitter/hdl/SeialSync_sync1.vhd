--
-- VHDL Architecture Splitter.SeialSync.sync1
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 15:45:51 22.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE sync1 OF SeialSync IS

 signal oldR : std_ulogic;
 signal oldLR : std_ulogic;
 signal cnt : unsigned(2 downto 0); 

BEGIN



    syncro : process(clock,reset)
    begin
        if (reset = '1') then
           oldR <= '0'; 
           cnt <= (others => '0');
        elsif rising_edge(clock) then  
            if DataReady = '0' and oldR = '1' then 
                oldR <= '0';   
                cnt <= cnt + 1;                
            elsif DataReady = '1' and oldR= '0' then
                oldR <= '1';
                
            end if;
             
            if cnt = 2 then 
                
                cnt <= (others => '0');
               audioRight1 <= lowPass  ;
                audioLeft1 <= highPass ;
            
            end if;
            
        end if;
    end process syncro;

END ARCHITECTURE sync1;

