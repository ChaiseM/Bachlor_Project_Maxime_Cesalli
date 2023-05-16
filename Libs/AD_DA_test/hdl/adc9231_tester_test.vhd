--
-- VHDL Architecture AD_DA_test.adc9231_tester.test
--
-- Created:
--          by - fabien.matter.UNKNOWN (WE7551)
--          at - 16:20:27 27.10.2021
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
library ieee;
	use ieee.math_real.all;
	
ARCHITECTURE test OF adc9231_tester IS

--clock
	constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
	signal clock_int: std_ulogic := '1';
	
--signals generation
	signal variableSignal: std_ulogic := '0';
	
--debug messages signal
	signal message: string(1 to 30);
BEGIN
  ------------------------------------------------------------------------------
                                                              -- clock
	clock_int <= not clock_int after clockPeriod/2;
	clock <= transport clock_int after clockPeriod*9/10;
	
															  -- Analog signals out
	VREF <= 1.0;--1V reference voltage
	outputAnalogSignals: process(clock)
	begin
		if rising_edge(clock) then
			if variableSignal = '1' then
				--report "real(now/1ps)/1.0e12 value is now: " & real'image(real(now/1ps)/1.0e12);
				VinA_pos <= amplitudeA*sin(2.0*MATH_PI*frequencyA*real(now/1ps )/1.0e12) + VREF;
				VinA_neg <= -amplitudeA*sin(2.0*MATH_PI*frequencyA*real(now/1ps)/1.0e12) + VREF;
				VinB_pos <= amplitudeB*sin(2.0*MATH_PI*frequencyB*real(now/1ps)/1.0e12) +  VREF;
				VinB_neg <= -amplitudeB*sin(2.0*MATH_PI*frequencyB*real(now/1ps)/1.0e12) + VREF;
			else
				VinA_pos <= -0.1;
			    VinA_neg <= 0.1;
			    VinB_pos <= -0.2;
			    VinB_neg <= 0.2;
			end if;
		end if;
	end process outputAnalogSignals;

  ------------------------------------------------------------------------------
                                                                -- test sequence
	process
	begin 
		message <= "Start -> ADC off              ";
		DFS_SCLK <= 'Z';
		SYNC <= '0';
		PDWN <= '0';
		DCS_SDIO <= '1';
		nCSB <= '1';
		nOEB <= '1'; --disable ADC outputs
		wait for 5*clockPeriod*regClkDiv;
		message <= "ADC ON, dataformat OFFSET     ";
		nOEB <= '0'; --enable ADC outputs
		DFS_SCLK <= '0'; --test dataformat offset
		wait for 10*clockPeriod*regClkDiv; --let acquire some samlpes with know value
		message <= "dataformat tst 2COMP          ";
		DFS_SCLK <= '1'; --test dataformat "twos complement"
		wait for 10*clockPeriod*regClkDiv; --let acquire some samlpes with know value
		message <= "start sinus signals           ";
		variableSignal <= '1'; --start input sinusoidal signals
		wait;
	end process;
END ARCHITECTURE test;

