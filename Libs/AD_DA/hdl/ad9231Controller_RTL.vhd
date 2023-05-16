library Common;
  use Common.CommonLib.all;
  
ARCHITECTURE RTL OF ad9231Controller IS
	signal prevClockA: std_ulogic;
	signal prevClockB: std_ulogic;
	signal risingEdgeDataClockA: std_ulogic;
	signal risingEdgeDataClockB: std_ulogic;
	signal fallingEdgeDataClockA: std_ulogic;
	signal fallingEdgeDataClockB: std_ulogic;
	signal txByteCounter: unsigned(counterBitNb(uppDmaBytePerLine)-1 downto 0);
BEGIN                                                                    -- ADC data clocks
	dataClocks: process(clock, reset)
	begin
		if reset = '1' then
			prevClockA <= '0';
			prevClockB <= '0';
		elsif rising_edge(clock) then
			prevClockA <= DCOA;
			prevClockB <= DCOB;
		end if;
	end process dataClocks;
	risingEdgeDataClockA <= '1' when (prevClockA = '0' and DCOA = '1') else '0';
	risingEdgeDataClockB <= '1' when (prevClockB = '0' and DCOB = '1') else '0';
	fallingEdgeDataClockA <= '1' when (prevClockA = '1' and DCOA = '0') else '0';
	fallingEdgeDataClockB <= '1' when (prevClockB = '1' and DCOB = '0') else '0';
	
	propagateData: process(clock, reset)							-- Data propagation
	begin															-- ORx is forwarded
		if reset = '1' then											-- in the remaining MSbs
			DOUT_A <= (others => 'Z');
			DOUT_B <= (others => 'Z');
		elsif rising_edge(clock) then
			if risingEdgeDataClockA = '1' then
				DOUT_A <= (adcBitNb-1 downto 0 => adcDataA, others => ORA);
			end if;
			if risingEdgeDataClockB = '1' then
				DOUT_B <= (adcBitNb-1 downto 0 => adcDataB, others => ORB);
			end if;
		end if;
	end process propagateData;
	
	propagateClocks: process(clock, reset)
	begin
		if reset = '1' then
			clk_A <= '0';
			clk_B <= '0';
		elsif rising_edge(clock) then
			if fallingEdgeDataClockA = '1' then
				clk_A <= '1';
			elsif risingEdgeDataClockA = '1' then
				clk_A <= '0';
			end if;
			if fallingEdgeDataClockB = '1' then
				clk_B <= '1';
			elsif risingEdgeDataClockB = '1' then
				clk_B <= '0';
			end if;
			
		end if;
	end process propagateClocks;
	en_A <= '1';
	en_B <= '1';
END ARCHITECTURE RTL;
