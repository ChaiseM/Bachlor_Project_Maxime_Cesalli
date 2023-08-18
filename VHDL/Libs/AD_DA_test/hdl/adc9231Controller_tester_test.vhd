library ieee;
	use ieee.math_real.all;
	
ARCHITECTURE test OF adc9231Controller_tester IS
--clock
	constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
	signal clock_int: std_ulogic := '1';

--adc 
	constant samplingPeriod: time := (1.0/adcClockFrequency) * 1 sec;


BEGIN
  ------------------------------------------------------------------------------
                                                              -- reset and clock
	reset <= '1', '0' after 2*clockPeriod;
	clock_int <= not clock_int after clockPeriod/2;
	clock <= transport clock_int after clockPeriod*9/10;
	
															  -- Analog signals out
	VREF <= 1.0;--1V reference voltage
	outputAnalogSignals: process(clock)
	begin
		if reset = '1' then
			VinA_neg <= 0.0;
			VinA_pos <= 0.0;
			VinB_neg <= 0.0;
			VinB_pos <= 0.0;
		elsif rising_edge(clock) then
			VinA_pos <= amplitudeA*sin(2.0*MATH_PI*signalAFrequency*real(now / 1 ps)/1.0E12) + VREF;
			VinA_neg <= -amplitudeA*sin(2.0*MATH_PI*signalAFrequency*real(now/ 1 ps)/1.0E12) + VREF;
			VinB_pos <= amplitudeB*sin(2.0*MATH_PI*signalBFrequency*real(now / 1 ps)/1.0E12) + VREF;
			VinB_neg <= -amplitudeB*sin(2.0*MATH_PI*signalBFrequency*real(now/ 1 ps)/1.0E12) + VREF;
		end if;
	end process outputAnalogSignals;

																-- ADC clock
	CLK <= not CLK after samplingPeriod/2 when reset = '0' else '0';
  ------------------------------------------------------------------------------
                                                                -- test sequence
	process
	begin           
		nOEB <= '1'; --disable ADC outputs
		wait until reset = '0';
		wait for 10*clockPeriod;
		nOEB <= '0'; --enable ADC outputs
		wait;
	end process;
  
	nCSB <= '1';
	DFS_SCLK <= 'Z';
	SYNC <= 'Z';--internal pulldown                                       
	PDWN <= '0';
	DCS_SDIO <= 'Z';
  
END ARCHITECTURE test;
