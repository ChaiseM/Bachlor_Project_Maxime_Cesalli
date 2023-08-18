library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc1801 IS
  --constant adcBitNb: positive := 16;
  signal sckToBckRatio: positive;
  signal BCK_delayed,LRCK_delayed: std_ulogic := '0';
  signal sckiCountsPerTlrck : natural := 0;
  signal sckiCounter,bckCounter: natural := 0;
  signal dataShiftRegisterL, dataShiftRegisterR: signed(adcBitNb-1 downto 0);
  signal currentSampleL,currentSampleR: signed(adcBitNb-1 downto 0) := (others=>'0');
  signal delayed_BCK: std_ulogic := '0';
  signal debug_signal: std_ulogic := '0';
BEGIN
  updateDelayedSignal: process(SCKI)					-- Delayed signals
  begin
	BCK_delayed <= BCK;
  end process;


  updateCounters: process(SCKI,BCK,LRCK)				-- Counters and load registers
  begin
	if rising_edge(LRCK) or falling_edge(LRCK) then 
		sckiCounter <= 0;
		bckCounter <= 0;
		if LRCK = '1' then
			currentSampleL <= VINL-VREF1;
			currentSampleR <= VINR-VREF2;
		end if;
	end if;
	if rising_edge(SCKI) then
		sckiCounter <= sckiCounter+1;
	end if;
	if rising_edge(BCK) then
		bckCounter <= bckCounter + 1;
	end if;
  end process;
  
  shiftValues: process(BCK_delayed)						-- Shift registers
	begin
	if falling_edge(BCK_delayed) then
		if bckCounter < adcBitNb then
			if FMT = '0' then		
				if LRCK = '0' then
					debug_signal <= not debug_signal;
					dataShiftRegisterL <= shift_left(currentSampleL,bckCounter);
				else
					dataShiftRegisterR <= shift_left(currentSampleR,bckCounter);
				end if;
			else--FMT='1'
				if (bckCounter > 0) then
					if LRCK = '0' then
						dataShiftRegisterL <= shift_left(currentSampleL,bckCounter-1);
					else
						dataShiftRegisterR <= shift_left(currentSampleR,bckCounter-1);
					end if;--LRCK
				end if;--bckCounter>0
			end if;--FMT,
		else
			dataShiftRegisterL <= (others => '0');
			dataShiftRegisterR <= (others => '0');
		end if;--bckCounter<adcBitNb;
	end if;--edge BCK;
  end process;

	DOUT <= dataShiftRegisterL(dataShiftRegisterL'left) when LRCK = '0'
		else dataShiftRegisterR(dataShiftRegisterR'left);

END ARCHITECTURE sim;