--
-- VHDL Architecture Frequency_test.ad9914Controller_tester.test
--
-- Created:
--          by - Melo-Matter.UNKNOWN (BUREAU)
--          at - 15:40:07 02/11/2021
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE test OF ad9914Controller_tester IS
  
	constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
	constant syncClkPeriod: time := (1.0/portClockFrequency) * 1 sec;
	signal clockInt: std_uLogic := '1';
	signal intSyncClk: std_ulogic := '1';
	
BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clocks
	reset <= '1', '0' after 2*clockPeriod;
	
	clockInt <= not clockInt after clockPeriod/2;
	clock <= transport clockInt after clockPeriod*9/10;
	intSyncClk <= not intSyncClk after syncClkPeriod;
	syncClk <= transport intSyncClk after syncClkPeriod*9/10;
	
END ARCHITECTURE test;

