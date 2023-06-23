--
-- VHDL Architecture Splitter.iisDecoder.MYArchi
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 10:49:17 13.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE MYArchi OF iisDecoder IS
    signal oldLRCK : std_ulogic;
    signal oldSCK : std_ulogic;
    signal oldSCK1 : std_ulogic := '0';
    signal LR : std_ulogic := '0';
    signal oldLR : std_ulogic := '0';
    signal lrSel : std_ulogic := '0';
    signal lrCounter : unsigned(4 downto 0);  -- count to 32
    

BEGIN

    countBits: process(reset, clock)
        variable  bitCounter : unsigned(4 downto 0);  -- count to 32
	begin
		if reset = '1' then
			lrCounter <= (others => '1');
            bitCounter := (others => '1');
            oldLRCK <= '0';
            oldSCK <= '0';
           
		elsif rising_edge(clock) then
            if LRCK = '0' and oldLRCK = '1' then 
                oldLRCK <= '0';
                bitCounter := (others => '1');
            elsif  LRCK = '1' and oldLRCK = '0' then 
                oldLRCK <= '1';
                bitCounter := (others => '1');
            end if ;
            
            if SCK = '0' and oldSCK = '1' then     
                oldSCK <= '0';
                bitCounter := bitCounter - 1;
                lrSel <= LRCK;
            elsif  SCK = '1' and oldSCK = '0' then 
                oldSCK <= '1';
                
            end if ; 
            lrCounter <= bitCounter + 2;
        end if;
    end process countBits;
    
  
   
    fillReg : process(clock , reset )
      
    begin
       
        if reset = '1' then
			
           
		elsif rising_edge(clock) then
         
            
            
            if SCK = '0' and oldSCK1 = '1' then     
                oldSCK1 <= '0';
            elsif  SCK = '1' and oldSCK1 = '0' then 
                oldSCK1 <= '1';
                if lrSel = '1' then 
                    audioLeft(to_integer(lrCounter)) <= DOUT;
                else
                    audioRight(to_integer(lrCounter)) <= DOUT;
                end if;
            end if ; 
          
          
        end if;
      
    
    end process fillReg;
    lr2 <= lrSel;
  --dataValid <= '1' when  lrCounter = 0 and SCK = '1' and LRCK = '1' else '0';     
    dataValid <= '1' when  lrCounter = 0 and SCK = '1' else '0';         
END ARCHITECTURE MYArchi;

