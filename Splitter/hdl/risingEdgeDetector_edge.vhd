
ARCHITECTURE edge OF risingEdgeDetector IS

    signal signalDelayed : std_logic;

BEGIN

    delaySignal : process(clock,reset)
    begin 
    
        if reset = '1' then
			signalDelayed <= '0';
		elsif rising_edge(clock) then
           signalDelayed <= DataValid;
        end if;
    end process delaySignal;
    
    en <= '1' when (DataValid = '1') and (signalDelayed = '0')
        else '0';
END ARCHITECTURE edge;

 