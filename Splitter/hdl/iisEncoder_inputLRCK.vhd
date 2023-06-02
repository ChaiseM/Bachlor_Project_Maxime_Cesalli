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
    signal leftShiftRegister : signed(audioLeft'range);
    signal rightShiftRegister : signed(audioRight'range);
     

begin

    FlipFlopAndResize: process(reset, clock)
	begin
		if reset = '1' then
			frameCounter <= (others => '0');
            leftShiftRegister <= (others => '0');
            rightShiftRegister <= (others => '0');
            
            pastI2SClock <= '0';
			
           -- switch <= '0';
		elsif rising_edge(clock) then
		
           
           
            if LRCK1 = '1' and pastLRCK = '0' then  
                pastLRCK <= '1'; 
                frameCounter <= (others => '0');
            elsif LRCK1 = '0' and pastLRCK = '1' then
                pastLRCK <= '0';
                frameCounter <= (others => '0');   
            end if ; 
            
            if CLKI2s = '1' and pastI2SClock = '0' then  
                pastI2SClock <= '1'; 
                 frameCounter <= frameCounter+1;
            elsif CLKI2s = '0' and pastI2SClock = '1' then
                pastI2SClock <= '0';
                
               
            end if;
               
                

            LRCK <= LRCK1;
            SCK <= CLKI2s;
            
            if LRCK1 = '1' then 
                DOUT <= leftShiftRegister(DATA_WIDTH-1); 
                leftShiftRegister <= shift_left(audioLeft,to_integer(frameCounter));
            else 
                DOUT <= rightShiftRegister(DATA_WIDTH-1); 
                rightShiftRegister <= shift_left(audioRight,to_integer(frameCounter));
            end if;            
            
          
           
		end if;
	end process FlipFlopAndResize;
END ARCHITECTURE inputLRCK;

