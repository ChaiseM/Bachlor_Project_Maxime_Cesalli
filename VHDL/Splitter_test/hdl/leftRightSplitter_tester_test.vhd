ARCHITECTURE test OF leftRightSplitter_tester IS
        
    signal frameCounter: unsigned(4 downto 0); -- count to 32
    constant clockPeriod: time := 1.0/clockFrequency * 1 sec;
    constant i2sClockPeriod: time := 1.0/2048000.0* 1 sec;
    signal sClock: std_uLogic := '1';
    signal i2sClock: std_uLogic := '1';
    signal sReset: std_uLogic;
    signal LR : std_uLogic;
    --signal switch: std_uLogic;
    signal pastI2SClock : std_uLogic;
    signal cnt : unsigned(databitnumbers-1 downto 0);
    signal shiftRegister :  unsigned(databitnumbers-1 downto 0);
  

BEGIN
  ------------------------------------------------------------------------------
  -- clock and reset
  --
    sReset <= '1', '0' after 4*clockPeriod;
    reset <= sReset;

    sClock <= not sClock after clockPeriod/2;
    clock <= transport sClock after 9.0/10.0 * clockPeriod;

    i2sClock <= not i2sClock after i2sClockPeriod/2;
    CLK_I <= transport i2sClock after 9.0/10.0 * i2sClockPeriod;

  
    FlipFlopAndResize: process(sReset, sClock)
	begin
		if sReset = '1' then
			frameCounter <= (others => '0');
            cnt <= (others => '0');
            LR <= '0';
            pastI2SClock <= '0';
           -- switch <= '0';
		elsif rising_edge(sClock) then
            
            if i2sClock = '1' and pastI2SClock = '0' then 
                frameCounter <= frameCounter+1;
                pastI2SClock <= '1'; 
                if frameCounter  = 0 then
                    cnt <= cnt + 1;
                    
                end if;         
  
            elsif i2sClock = '0' and pastI2SClock = '1' then
                pastI2SClock <= '0';
                if frameCounter + 1 = 0 then
                    LR <=  not LR; 
                end if;
            end if ; 

            LR_I <= LR;
            Data_I <= shiftRegister(23); 
            shiftRegister <= shift_left(cnt,to_integer(frameCounter));
            
		end if;
	end process FlipFlopAndResize;
    
  

END ARCHITECTURE test;
