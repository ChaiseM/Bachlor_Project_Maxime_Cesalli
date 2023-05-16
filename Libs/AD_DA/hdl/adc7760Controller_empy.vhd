ARCHITECTURE empty OF adc7760Controller IS

BEGIN

  MCLK <= '0';
  RESET_n <= not '0';
  SYNC_n <= not '0';
  CS_n <= (others => not '0');
  WR_RD_n <= '1';

  DB <= (others => 'Z');

END ARCHITECTURE empty;
