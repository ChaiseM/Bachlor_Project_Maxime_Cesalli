
ARCHITECTURE iis OF iisResizer IS

    signal tempR : signed(audioRightO'range);
    signal tempL : signed(audioLeftO'range);
    

BEGIN

    FlipFlopAndResize: process(reset, clock)
	begin
		if reset = '1' then
			tempR <= (others => '0');
			tempL <= (others => '0');
            audioLeftO  <= (others => '0');
            audioRightO <= (others => '0');
		elsif rising_edge(clock) then
            if dataValidI = '1' then
                tempR <= shift_left(resize(audioRightI,tempR'length),(audioRightO'length-audioRightI'length));
                tempL <= shift_left(resize(audioLeftI,tempL'length),(audioLeftO'length-audioLeftI'length));
            end if;
            if ShiftData ='1' then
                    audioRightO <= tempR;
                    audioLeftO <= tempL;
            end if;
		end if;
	end process FlipFlopAndResize;
    


END ARCHITECTURE iis;

