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

ENTITY StoM IS
    GENERIC( 
        signalOBitNb : positive := 32
    );
    PORT( 
        audioLeft  : IN     signed (signalOBitNb-1 DOWNTO 0);
        audioRight : IN     signed (signalOBitNb-1 DOWNTO 0);
        audioMono  : OUT    signed (signalOBitNb-1 DOWNTO 0);
        clock      : IN     std_ulogic;
        reset      : IN     std_ulogic
    );

-- Declarations

END StoM ;

--
ARCHITECTURE iis OF StoM IS

    signal temp :  signed (signalOBitNb DOWNTO 0);
    
BEGIN

    stereoToMono : process(clock,reset) 
    begin
        if reset = '1' then
			temp <= (others => '0');
		elsif rising_edge(clock) then
            temp <= shift_right(resize(audioRight,audioRight'length+1)+resize(audioLeft,audioLeft'length+1),1);
            audioMono <= resize(temp,audioMono'length);
        end if;
    end process stereoToMono;



END ARCHITECTURE iis;

