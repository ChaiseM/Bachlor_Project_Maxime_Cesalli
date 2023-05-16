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
-- Declarations
    generic(
        signalBitNb : positive := 32
	);

	port(
        reset		: in std_ulogic;
        clock  		: in std_ulogic; 
        audioLeft 	: in signed(signalBitNb-1 downto 0);
        audioRight 	: in signed(signalBitNb-1 downto 0);
        LRCK 		: out std_ulogic;
        SCK			: out std_ulogic;
        DOUT  		: out std_ulogic;
        ShiftData 	: out std_ulogic
	);
END iisEncoder ;

--
ARCHITECTURE iis OF iisEncoder IS
   
    constant frameLength : positive := 2*2*signalBitNb;
    constant frameCounterBitNb : positive := requiredBitNb(frameLength-1);

    signal frameCounter : unsigned(frameCounterBitNb-1 downto 0);
    signal leftShiftRegister : unsigned(audioLeft'range);
    signal rightShiftRegister : unsigned(audioRight'range);

begin

    countFrame: process(reset, clock)
    begin
        if reset = '1' then
            frameCounter <= (others => '0');
        elsif rising_edge(clock) then
            frameCounter <= frameCounter + 1;
        end if;
    end process countFrame;

    shiftRegisters: process(reset, clock)
    begin
        if reset = '1' then
            leftShiftRegister  <= (others => '0');
            rightShiftRegister <= (others => '0');
        elsif rising_edge(clock) then
            if frameCounter = 0 then
                leftShiftRegister <= unsigned(audioLeft);
                rightShiftRegister <= unsigned(audioRight);
            elsif frameCounter(0) = '1' then
                if frameCounter(frameCounter'high-1 downto 0) > 1 then
                    if (frameCounter(frameCounter'high) = '0') then
                        leftShiftRegister <= shift_left(leftShiftRegister, 1);
                    else
                        rightShiftRegister <= shift_left(rightShiftRegister, 1);
                    end if;
                end if;
            end if;
        end if;
    end process shiftRegisters;

    LRCK <= frameCounter(frameCounter'high);
    SCK <= frameCounter(0);
    DOUT <= '0' when frameCounter(frameCounter'high-1 downto 0) <= 1
        else leftShiftRegister(leftShiftRegister'high)
            when frameCounter(frameCounter'high) = '0'
        else rightShiftRegister(rightShiftRegister'high);

        shiftData <= '1' when frameCounter+1 = 0
        else '0';
        
END ARCHITECTURE iis;

