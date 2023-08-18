ARCHITECTURE RTL OF adc5368_synchInputs IS
BEGIN
  ------------------------------------------------------------------------------
                                                           -- synchronize inputs
  synchInputs: process(clock, reset)
  begin
    if reset = '1' then
      sclk_synch     <= '0';
      lrck_synch     <= '0';
      sdout1_synch   <= '0';
      sdout2_synch   <= '0';
      sdout3_synch   <= '0';
      sdout4_synch   <= '0';
      adc_ovfl_synch <= '0';
    elsif rising_edge(clock) then
      sclk_synch     <= sclk;
      lrck_synch     <= lrck;
      sdout1_synch   <= sdout1;
      sdout2_synch   <= sdout2;
      sdout3_synch   <= sdout3;
      sdout4_synch   <= sdout4;
      adc_ovfl_synch <= not adc_ovfl_n;
    end if;
  end process synchInputs;

END ARCHITECTURE RTL;
