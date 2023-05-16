ARCHITECTURE test OF sineCosineGenerator_tester IS

   constant clockFrequency: real := 66.0E6;
   constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
   signal clock_int: std_uLogic := '1';

BEGIN

   ------------------------------------------------------------------------------
   -- reset and clock
   reset <= '1', '0' after 2*clockPeriod;

   clock_int <= not clock_int after clockPeriod/2;
   clock <= transport clock_int after clockPeriod*9/10;
      
   ------------------------------------------------------------------------------

   data : process
   begin
      amp0 <= X"4DB5";
      step <= X"000000";
      wait for 10 us;
   
      step <= X"000001";
      wait for 1000 ms;
      
      -- step <= X"00634C";
      -- wait for 2 ms;
      
      -- step <= X"00C698";
      -- wait for 2 ms;
      
      -- step <= X"03E0F8";
      -- wait for 2 ms;
      
      -- step <= X"0F83E1";
      -- wait for 2 ms;
      
      wait;
   
   end process data;
   
END ARCHITECTURE test;