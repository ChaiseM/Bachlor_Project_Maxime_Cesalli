-------------------------------------------
-- detecting the risingEdge of a sinal
-------------------------------------------
ARCHITECTURE edge OF risingEdgeDetector IS

   signal signalDelayed : std_logic;

BEGIN

   delaySignal : process(clock,reset)
   begin 

   if reset = '1' then
      signalDelayed <= '0';
   elsif rising_edge(clock) then
      -- delaying the signal 
      signalDelayed <= DataValid;
   end if;
end process delaySignal;
   -- detecting the rising dege and updating the output
   en <= '1' when (DataValid = '1') and (signalDelayed = '0') else '0';
   
END ARCHITECTURE edge;

