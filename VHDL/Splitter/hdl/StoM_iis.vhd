--
-- VHDL Architecture Splitter.StereoToMono.iis
--
-- Created:
--          by - maxim.UNKNOWN (DESKTOP-ADLE19A)
--          at - 14:02:34 23/05/2023
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



--
ARCHITECTURE iis OF StoM IS

    signal temp1 :  signed (audioRight'length downto 0);
    signal temp2 :  signed (audioRight'range);
    
BEGIN

    stereoToMono : process(clock,reset) 
    begin
        if reset = '1' then
			temp1 <= (others => '0');
            temp2 <= (others => '0');
		elsif rising_edge(clock) then
            --temp1 <= resize(shift_right((resize(audioRight,temp1'length+1)+audioLeft),1),temp1'length);
            temp1 <= resize(audioRight,temp1'length)+audioLeft;
            temp2 <= resize(shift_right(temp1,1),temp2'length);
            audioMono <= temp2;
            
        end if;
    end process stereoToMono;



END ARCHITECTURE iis;

