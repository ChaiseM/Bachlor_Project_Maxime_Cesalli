--
-- VHDL Architecture Splitter.iisResizer.iis
--
-- Created:
--          by - maxim.UNKNOWN (DESKTOP-ADLE19A)
--          at - 13:34:14 16/05/2023
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

ENTITY iisResizer IS
    GENERIC( 
        signalIBitNb : positive := 24;
        signalOBitNb : positive := 32
    );
    PORT( 
        dataValidI  : IN     std_ulogic;
        audioLeftI  : IN     signed (signalIBitNb-1 DOWNTO 0);
        audioRightI : IN     signed (signalIBitNb-1 DOWNTO 0);
        ShiftData   : IN     std_ulogic;
        audioLeftO  : OUT    signed (signalOBitNb-1 DOWNTO 0);
        audioRightO : OUT    signed (signalOBitNb-1 DOWNTO 0);
        clock       : IN     std_ulogic;
        reset       : IN     std_ulogic
    );

-- Declarations

END iisResizer ;

--
ARCHITECTURE iis OF iisResizer IS

    signal tempR : signed(signalOBitNb-1 DOWNTO 0);
    signal tempL : signed(signalOBitNb-1 DOWNTO 0);
    signal cnt: unsigned(1 downto 0); 

BEGIN

    FlipFlopAndResize: process(reset, clock)
	begin
		if reset = '1' then
			tempR <= (others => '0');
            cnt <= (others => '0');
			tempL <= (others => '0');
            audioLeftO  <= (others => '0');
            audioRightO <= (others => '0');
		elsif rising_edge(clock) then
            if dataValidI = '1' then
                cnt <= to_unsigned(2,cnt'length);
                tempR <= shift_left(resize(audioRightI,tempR'length),(signalOBitNb-signalIBitNb));
                tempL <= shift_left(resize(audioLeftI,tempL'length),(signalOBitNb-signalIBitNb));
                --tempR <= audioRightI;
                --tempL <= audioLeftI;    
            end if;
            if ShiftData ='1' then
                --if cnt = 2 then 
                    audioRightO <= tempR;
                    --cnt <= cnt-1;
                --elsif cnt = 1 then 
                    audioLeftO <= tempL;
                    --cnt <= cnt-1;
                --end if;
            end if;
		end if;
	end process FlipFlopAndResize;
    


END ARCHITECTURE iis;

