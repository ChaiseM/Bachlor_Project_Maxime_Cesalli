--
-- VHDL Architecture Splitter.delayer.delay1
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 14:20:38 03.07.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE delay1 OF delayer IS
BEGIN
    delaySignal : process(clock,reset)
    begin 
    
        if reset = '1' then
			data_delayed <= '0';
		elsif rising_edge(clock) then
           data_delayed <= Data;
        end if;
    end process delaySignal;
    
END ARCHITECTURE delay1;

