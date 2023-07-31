-------------------------------------------------------------
-- delaying the signal to take into account the sync register 
-------------------------------------------------------------

ARCHITECTURE delay1 OF delayer IS
BEGIN
    delaySignal : process(clock,reset)
    begin 
       
        if reset = '1' then
			data_delayed <= '0';
		elsif rising_edge(clock) then
            -- delay the siganl by 1 clock period 
           data_delayed <= Data;
        end if;
    end process delaySignal;
    
END ARCHITECTURE delay1;

