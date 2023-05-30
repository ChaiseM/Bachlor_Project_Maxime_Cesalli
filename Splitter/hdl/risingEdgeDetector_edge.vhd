
ARCHITECTURE edge OF risingEdgeDetector IS

    signal oldSignal : std_logic;

BEGIN

    risingEdge : process(clock,reset)
    begin 
    
        if reset = '1' then
			oldSignal <= '0';
		elsif rising_edge(clock) then
            en <= '0';
            if dataValid = '1' and oldSignal = '0' then 
                en <= '1';
                oldSignal <= '1';
            elsif  dataValid = '0' and oldSignal = '1' then 
                 oldSignal <= '0';
            end if;
        end if ;  
    end process risingEdge;

END ARCHITECTURE edge;

