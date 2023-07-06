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

 signal cnt :  unsigned (2 downto 0);

BEGIN

    FlipFlopAndResize: process(reset, clock)
	begin
		if reset = '1' then
			audio_R_out <= (others => '0');
            audio_L_out <= (others => '0');
            cnt <= (others => '0');
		elsif rising_edge(clock) then
            -- if dataValid = '1' then
                -- cnt <= cnt + 1;
            -- end if;
            -- if cnt = 2 then 
                -- cnt <= (others => '0');
                -- audio_R_out <= audio_R_in;
                -- audio_L_out <= audio_L_in;
            -- end if ;
            if dataValid = '1' then
               audio_R_out <= audio_R_in;
               audio_L_out <= audio_L_in;      
            end if;

                      
		end if;
	end process FlipFlopAndResize;



END ARCHITECTURE test_lowpas_i2s;

