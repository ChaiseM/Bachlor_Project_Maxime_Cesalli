--
-- VHDL Architecture Splitter.iisEncoder.iis
--
-- Created:
--          by - maxim.UNKNOWN (DESKTOP-ADLE19A)
--          at - 13:34:30 16/05/2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;  
LIBRARY gates;
  USE gates.gates.all;
LIBRARY Common;
  USE Common.CommonLib.all;

ARCHITECTURE iis OF iisEncoder IS
   
    constant frameLength : positive := audioLeft'length;
    constant frameCounterBitNb : positive := requiredBitNb(frameLength-1);
    signal pastI2SClock : std_uLogic;
    signal LR : std_uLogic;
	
	signal tempCnt : unsigned(10 downto 0);
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
            LR <= '0';
            pastI2SClock <= '0';
			tempCnt <= (others => '0');
           -- switch <= '0';
		elsif rising_edge(clock) then
		
           
            if CLKI2s = '1' and pastI2SClock = '0' then 
               
                pastI2SClock <= '1'; 
                
  
            elsif CLKI2s = '0' and pastI2SClock = '1' then
                pastI2SClock <= '0';
				ShiftData <= '0';
                frameCounter <= frameCounter+1;
				if frameCounter + 1 = 0 then
                    ShiftData <= '1';
					LR <=  not LR; 
                end if;
            end if ; 

            LRCK <= LR;
            SCK <= CLKI2s;
            if LR = '1' then 
				DOUT <= leftShiftRegister(DATA_WIDTH-1); 
                leftShiftRegister <= shift_left(audioLeft,to_integer(frameCounter));
            else 
				DOUT <= rightShiftRegister(DATA_WIDTH-1); 
                rightShiftRegister <= shift_left(audioRight,to_integer(frameCounter));
                
            end if;
           
		end if;
	end process FlipFlopAndResize;
        
END ARCHITECTURE iis;
