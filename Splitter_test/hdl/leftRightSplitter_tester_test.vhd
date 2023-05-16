ARCHITECTURE test OF leftRightSplitter_tester IS
                                                              -- clock and reset
  constant clockPeriod: time := 1.0/clockFrequency * 1 sec;
  constant i2sClockPeriod := 1.0/(2.0*24.0*44100.0)* 1 sec;
  constant bitNB := to_unsigned(24,frameCounter'length);
  signal sClock: std_uLogic := '1';
  signal i2sClock: std_uLogic := '1';
  signal sReset: std_uLogic;
  signal frameCounter: unsigned(3 downto 0); -- count to 32
  signal LR : std_uLogic;
  signal cnt : unsigned(bitNB-1 downto 0);
  

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
			frameCounter <= (others <= '0');
		elsif rising_edge(sClock) then
        
            if frameCounter  = 24 then
                frameCounter <= (others <= '0');
                if LR = '0' then 
                    LR <= '1';
                    cnt <= cnt + 1;
                else
                    LR <= '0';
                    cnt <= cnt + 1;
                end if;
            else
                frameCounter <= frameCounter+1;
            end if;
		end if;
	end process FlipFlopAndResize;
  
  LR_I <= LR;
  Data_I <= cnt;
  
  
  

END ARCHITECTURE test;
