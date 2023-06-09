--
-- VHDL Architecture Splitter_test.bascule.test_lowpas_i2s
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 15:08:13 30.05.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE test_lowpas_i2s OF bascule IS

 

BEGIN

    FlipFlopAndResize: process(reset, clock)
	begin
		if reset = '1' then
			audio_R_out <= (others => '0');
            audio_L_out <= (others => '0');
		elsif rising_edge(clock) then
            if dataValid = '1' then
                 audio_R_out <= shift_right(signed(shift_left(unsigned(audio_R_in),1)),1);
                 audio_L_out <= shift_right(signed(shift_left(unsigned(audio_L_in),1)),1);
            end if;
		end if;
	end process FlipFlopAndResize;



END ARCHITECTURE test_lowpas_i2s;

