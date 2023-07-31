--------------------------------------------------------------------------------
-- ensures the syncro between the Xover and the i2s encoder 
-- also devides the highpass signal by 2 to account for the higher 
-- efficency of the tweeter
--------------------------------------------------------------------------------
ARCHITECTURE sync1 OF SeialSync IS
	signal oldR : std_ulogic;
	signal oldLR : std_ulogic;
	signal cnt : unsigned(2 downto 0);
	signal tempLow : signed(lowPass'range);
	signal tempHigh : signed(highPass'range);
BEGIN
	syncro : process (clock, reset)
	begin
		if (reset = '1') then
			oldR <= '0';
			oldLR <= '0';
			cnt <= (others => '0');
			tempHigh <= (others => '0');
			tempLow <= (others => '0');
		elsif rising_edge(clock) then
			if DataReady = '1' then
				tempLow <= lowPass;
				tempHigh <= highPass;
				tempLow(0) <= '0';
				tempLow(1) <= '0';
				tempLow(2) <= '0';
				tempHigh(0) <= '0';
				tempHigh(1) <= '0';
				tempHigh(2) <= '0';
			end if;
			audioRight1 <= tempLow;
			-- to account for the higher efficency of the twitter
			audioLeft1 <= shift_right(tempHigh, 1);
		end if;
	end process syncro;
END ARCHITECTURE sync1;