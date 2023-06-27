--
-- VHDL Architecture Splitter.iisEncoder.inputLRCK
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 08:46:24 02.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
--
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;  
LIBRARY gates;
  USE gates.gates.all;
LIBRARY Common;
  USE Common.CommonLib.all;
  
ARCHITECTURE inputLRCK OF iisEncoder IS
    constant frameLength : positive := audioLeft'length;
    constant frameCounterBitNb : positive := requiredBitNb(frameLength-1);
    signal pastI2SClock : std_uLogic;
    signal pastLRCK : std_uLogic;
    signal frameCounter : unsigned(frameCounterBitNb-1 downto 0);
    signal frameCounter2 : unsigned(frameCounterBitNb-1 downto 0);
    signal LRCKShifted :  std_uLogic;
    constant maxFrameNBR : unsigned(frameCounter'range) := (others => '1');
    signal leftShiftRegister : signed(audioLeft'range);
    signal rightShiftRegister : signed(audioRight'range);
    signal dummy1 : unsigned(audioLeft'range);
    signal dummy2 : unsigned(audioRight'range);
     

begin

    FlipFlopAndResize: process(reset, clock)
	begin
		if reset = '1' then
			frameCounter <= (others => '0');
            frameCounter2 <= (others => '0');
            leftShiftRegister <= (others => '0');
            rightShiftRegister <= (others => '0');
            pastI2SClock <= '0';
			pastLRCK <= '0';
            LRCKShifted <= '0';
           -- switch <= '0';
		elsif rising_edge(clock) then
		     
            NewData <= '0';

            if CLKI2s = '1' and pastI2SClock = '0' then  
                pastI2SClock <= '1';                
                frameCounter <= frameCounter-1; 
                LRCKShifted  <= LRCK1;              
                          
            elsif CLKI2s = '0' and pastI2SClock = '1' then
                pastI2SClock <= '0';
                
                if LRCK1 = '0' then 
                    DOUT <= leftShiftRegister(to_integer(frameCounter));
                else 
                    DOUT <= rightShiftRegister(to_integer(frameCounter)) ; 
                end if;       
                frameCounter2 <= frameCounter;
               
            end if;  
             
            if LRCKShifted = '1' and pastLRCK = '0' then  
                pastLRCK <= '1'; 
                frameCounter <= (others => '1');
                      
            elsif LRCKShifted = '0' and pastLRCK = '1' then
                pastLRCK <= '0';
                frameCounter <= (others => '1'); 
                    
            end if ; 
            
            if frameCounter = 3 and LRCKShifted = '1' and CLKI2s = '0' then 
                NewData <= '1';
            end if ;
            if frameCounter = 3 and LRCKShifted = '1' and CLKI2s = '1' then 
                rightShiftRegister <= audioRight;
                leftShiftRegister <= audioLeft;
            end if ;
           
        LRCK <= LRCK1;  
        SCK <= CLKI2s;
      
       
  
           
		end if;
	end process FlipFlopAndResize;
    
    
  -- DOUT <= leftShiftRegister(to_integer(frameCounter))when LRCK1 = '1' 
   --else rightShiftRegister(to_integer(frameCounter)) ;
    
    
END ARCHITECTURE inputLRCK;