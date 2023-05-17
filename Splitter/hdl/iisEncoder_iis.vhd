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

ENTITY iisEncoder IS
    GENERIC( 
        signalBitNb : positive := 32
    );
    PORT( 
        reset      : IN     std_ulogic;
        clock      : IN     std_ulogic;
        audioLeft  : IN     signed (signalBitNb-1 DOWNTO 0);
        audioRight : IN     signed (signalBitNb-1 DOWNTO 0);
        LRCK       : OUT    std_ulogic;
        SCK        : OUT    std_ulogic;
        DOUT       : OUT    std_ulogic;
        ShiftData  : OUT    std_ulogic;
        CLKI2s     : IN     std_ulogic
    );

-- Declarations

END iisEncoder ;

--
ARCHITECTURE iis OF iisEncoder IS
   
    constant frameLength : positive := signalBitNb;
    constant frameCounterBitNb : positive := requiredBitNb(frameLength-1);
    signal pastI2SClock : std_uLogic;
    signal LR : std_uLogic;
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
           -- switch <= '0';
		elsif rising_edge(clock) then
            
            if CLKI2s = '1' and pastI2SClock = '0' then 
                ShiftData <= '0';
                frameCounter <= frameCounter+1;
                pastI2SClock <= '1'; 
                if frameCounter  = 0 then
                    ShiftData <= '1';
                end if;         
  
            elsif CLKI2s = '0' and pastI2SClock = '1' then
                pastI2SClock <= '0';
                if frameCounter + 1 = 0 then
                    LR <=  not LR; 
                end if;
            end if ; 

            LRCK <= LR;
            SCK <= CLKI2s;
            if LR = '1' then 
                DOUT <= rightShiftRegister(signalBitNb-1); 
                rightShiftRegister <= shift_left(audioRight,to_integer(frameCounter));
            else 
                DOUT <= leftShiftRegister(signalBitNb-1); 
                leftShiftRegister <= shift_left(audioLeft,to_integer(frameCounter));
            end if;
           
		end if;
	end process FlipFlopAndResize;
        
END ARCHITECTURE iis;

