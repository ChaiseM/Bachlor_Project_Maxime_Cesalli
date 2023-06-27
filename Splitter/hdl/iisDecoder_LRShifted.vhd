--
-- VHDL Architecture Splitter.iisDecoder.LRShifted
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 11:08:28 26.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE LRShifted OF iisDecoder IS

    signal frameCounter : unsigned (4 downto 0); -- count to 32
    signal oldSCK : std_ulogic;  
    signal oldSCK1 : std_ulogic;  
    signal oldLRCK : std_ulogic;    
    signal LRCKShifted : std_ulogic; 
    signal LRCKShifted2 : std_ulogic; 
    signal tempRight : signed(DATA_WIDTH-1 downto 0);
    signal tempLeft : signed(DATA_WIDTH-1 downto 0);
BEGIN

    bitCounter : process(clock, reset)
    begin 
        if reset = '1' then
        
            frameCounter <= (others  => '1');
            oldSCK <= '0';
            
            oldLRCK <= '0';
		elsif rising_edge(clock) then
        
            if SCK = '1' and oldSCK = '0' then 
                oldSCK <= '1';
                
            elsif SCK = '0' and oldSCK = '1' then 
                oldSCK <= '0';
                frameCounter <= frameCounter - 1;
                LRCKShifted <= LRCK; -- shifting of LRCK to comply with I2s Specs
                LRCKShifted2 <= LRCKShifted; 
            end if;
            
            if LRCKShifted2 = '1' and oldLRCK = '0' then 
                oldLRCK <= '1';
                frameCounter <= (others  => '1');
            elsif LRCKShifted2 = '0' and oldLRCK = '1' then 
                oldLRCK <= '0'; 
                frameCounter <= (others  => '1');
            end if;
            
        end if;
    
    end process bitCounter;
    
    fillReg : process(clock , reset ) 
    begin
        if reset = '1' then
		
            oldSCK1 <= '0';
           
		elsif rising_edge(clock) then
         
            
            
            if SCK = '0' and oldSCK1 = '1' then     
                oldSCK1 <= '0';
            elsif  SCK = '1' and oldSCK1 = '0' then 
                oldSCK1 <= '1';
                if LRCKShifted = '1' then 
                    audioLeft(to_integer(frameCounter)) <= DOUT;
                else
                    audioRight(to_integer(frameCounter)) <= DOUT;
                end if;
            end if ; 
          
          
        end if;
      
    
    end process fillReg;
     lr2 <= LRCKShifted;
    dataValid <= '1' when  frameCounter = 0   else '0';    

END ARCHITECTURE LRShifted;

