library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc9231 IS
	type formatEnum is (offset_binary, twos_complement);
	signal selectedFormat: formatEnum := twos_complement;
	signal clockCounter: unsigned(2 downto 0) := (others => '0');
	signal dividedClock: std_ulogic := '0';
	signal intORA: std_ulogic := '0';
	signal intORB: std_ulogic := '0';
	signal risingEdgeDividedClock: std_ulogic;
	signal fallingEdgeDividedClock: std_ulogic;
	signal prevdividedClock: std_ulogic := '0';
	signal intValueA: real;
	signal intValueB: real;
	signal nOEBPrev: std_ulogic := '0';

BEGIN
  ------------------------------------------------------------------------------
														-- voltage calculation
														-- and overflow output
	intValueA <= VinA_pos-VinA_neg;
	intValueB <= VinB_pos-VinB_neg;
														-- see datasheet table 12
	intORA <= '1' when intValueA < -VREF or intValueA > VREF else '0';
	intORB <= '1' when intValueB < -VREF or intValueB > VREF else '0';
	
	DCS_SDIO <= 'Z';													-- clock divider
	clockDivider: process(CLK)
    begin
		if rising_edge(CLK) then
			if SYNC = '1' then
				clockCounter <= (others => '0');
				dividedClock <= '0';
			else
				if clockCounter < regClkDiv - 1 then
					clockCounter <= clockCounter + 1;
				else
					clockCounter <= (others => '0');
					dividedClock <= not dividedClock;
				end if;
			end if;
		end if;
	end process clockDivider;
	
	prevSignals: process(CLK)
	begin
		if rising_edge(CLK) then
			prevdividedClock <= dividedClock;
			nOEBPrev <= nOEB;
		end if;
	end process prevSignals;
	
    risingEdgeDividedClock <= '1' when (prevdividedClock = '0' and dividedClock = '1') else '0';                                                    -- data format selection
	fallingEdgeDividedClock <= '1' when (prevdividedClock = '1' and dividedClock = '0') else '0';
	
	changeDataFormat: process(CLK)
	begin
		if rising_edge(CLK) then
			if nCSB = '1' then
				if DFS_SCLK = '1' then
					selectedFormat <= twos_complement;
				else
					selectedFormat <= offset_binary;
				end if;
			end if;
		end if;
	end process changeDataFormat;
														-- output signals
	process(CLK)
	begin
		if rising_edge(CLK) then
			if nOEB = '0' then
				if nOEBPrev = '1' then
					DCOA <= '0';
					DCOB <= '0';
				elsif risingEdgeDividedClock <= '1' then
					DCOA <= not DCOA;
					DCOB <= not DCOB;
				end if;
				if fallingEdgeDividedClock = '1' then
					if selectedFormat = twos_complement then
						if intORA = '0' then
							DOUT_A <= std_ulogic_vector(to_signed(integer(intValueA*2.0**(adcBitNb-1)/VREF), DOUT_A'length));
						else
							DOUT_A <= (DOUT_A'left => '1', others => '0') when intValueA < 0.0 else (DOUT_A'left => '0', others => '1');
						end if;
						if intORB = '0' then
							DOUT_B <= std_ulogic_vector(to_signed(integer(intValueB*2.0**(adcBitNb-1)/VREF), DOUT_B'length));
						else
							DOUT_B <= (DOUT_B'left => '1', others => '0') when intValueB < 0.0 else (DOUT_B'left => '0', others => '1');
						end if;
					elsif selectedFormat = offset_binary then
						if intORA = '0' then
							DOUT_A <= std_ulogic_vector(to_unsigned(integer((intValueA+VREF)*2.0**(adcBitNb-1)/VREF), DOUT_A'length));
						else 
							DOUT_A <= (others => '0') when intValueA < 0.0 else (others => '1');
						end if;
						if intORB = '0' then
							DOUT_B <= std_ulogic_vector(to_unsigned(integer((intValueB+VREF)*2.0**(adcBitNb-1)/VREF), DOUT_B'length));
						else
							DOUT_B <= (others => '0') when intValueB < 0.0 else (others => '1');
						end if;
					end if;
					ORA <= intORA;
					ORB <= intORB;
				end if;
			else
				DOUT_A <= (others => 'Z');
				DOUT_B <= (others => 'Z');
				ORA <= '0';
				ORB <= '0';
				DCOA <= 'Z';
				DCOB <= 'Z';
			end if;
		end if;
	end process;
END ARCHITECTURE sim;
