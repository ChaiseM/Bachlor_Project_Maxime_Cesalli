--------------------------------------------------------------
-- register to sync the iis decoder with the others blocks 
--------------------------------------------------------------
ARCHITECTURE test_lowpas_i2s OF bascule IS
   signal cnt :  unsigned (2 downto 0);
BEGIN
   FlipFlopAndResize: process(reset, clock)
   begin
      if reset = '1' then
         audio_R_out <= (others => '0');
         audio_L_out <= (others => '0');
         cnt <= (others => '0');
      elsif rising_edge(clock) then
         if dataValid = '1' then
            audio_R_out <= audio_R_in;
            audio_L_out <= audio_L_in;      
         end if;             
      end if;
   end process FlipFlopAndResize;
END ARCHITECTURE test_lowpas_i2s;

