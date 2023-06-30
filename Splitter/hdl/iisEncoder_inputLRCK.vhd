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

    signal lrckDelayed, lrckChanged : std_ulogic;
    signal sckDelayed, sckRising, sckFalling : std_ulogic;
    constant frameLength : positive := audioLeft'length;
    constant frameCounterBitNb : positive := requiredBitNb(frameLength-1);
  
   
    signal frameCounter : unsigned(frameCounterBitNb-1 downto 0);
    signal LRCKShifted :  std_uLogic;
    signal leftShiftRegister : signed(audioLeft'range);
    signal rightShiftRegister : signed(audioRight'range);
  

begin

    delaySck: process(reset, clock)
	begin
		if reset = '1' then
			sckDelayed <= '0';
            lrckDelayed <= '0';
		elsif rising_edge(clock) then
            sckDelayed <= CLKI2s;
            lrckDelayed <= LRCK1;
        end if;
    end process delaySck;
    
    sckRising <= '1' when (CLKI2s = '1') and (sckDelayed = '0')
        else '0';

    sckFalling <= '1' when (CLKI2s = '0') and (sckDelayed = '1')
        else '0';

    lrckChanged <= '1' when LRCK1 /= lrckDelayed
        else '0';

    FlipFlopAndResize: process(reset, clock)
	begin
		if reset = '1' then
			frameCounter <= (others => '0');
            leftShiftRegister <= (others => '0');
            rightShiftRegister <= (others => '0');

            LRCKShifted <= '0';
           -- switch <= '0';
		elsif rising_edge(clock) then
		     
            NewData <= '0';

            if sckRising = '1' then            
                frameCounter <= frameCounter-1; 
                LRCKShifted  <= LRCK1;              
                          
            elsif sckFalling = '1' then
                if LRCKShifted = '0' then 
                    DOUT <= leftShiftRegister(to_integer(frameCounter));
                else 
                    DOUT <= rightShiftRegister(to_integer(frameCounter)) ; 
                end if;       
            end if;  
             
            if lrckChanged = '1' then  
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
        Frameout0 <= frameCounter(0);
		end if;
	end process FlipFlopAndResize;
    
    
  -- DOUT <= leftShiftRegister(to_integer(frameCounter))when LRCK1 = '1' 
   --else rightShiftRegister(to_integer(frameCounter)) ;
    
    
END ARCHITECTURE inputLRCK;     