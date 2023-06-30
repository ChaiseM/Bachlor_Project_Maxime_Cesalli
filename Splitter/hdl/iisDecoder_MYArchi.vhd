--
-- VHDL Architecture Splitter.iisDecoder.MYArchi
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 10:49:17 13.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE MYArchi OF iisDecoder IS

    signal sckDelayed, sckRising, sckFalling : std_ulogic;
    signal lrckDelayed, lrckChanged : std_ulogic;

    signal oldLRCK : std_ulogic;
    signal oldSCK : std_ulogic;
--    signal oldSCK1 : std_ulogic;
    signal lrSel1, lrSel : std_ulogic;
    signal lrCounter1, lrCounter : unsigned(4 downto 0);  -- count to 32
    

BEGIN

    delaySck: process(reset, clock)
	begin
		if reset = '1' then
			sckDelayed <= '0';
            lrckDelayed <= '0';
		elsif rising_edge(clock) then
            sckDelayed <= SCK;
            lrckDelayed <= LRCK;
        end if;
    end process delaySck;

    sckRising <= '1' when (SCK = '1') and (sckDelayed = '0')
        else '0';

    sckFalling <= '1' when (SCK = '0') and (sckDelayed = '1')
        else '0';

    lrckChanged <= '1' when LRCK /= lrckDelayed
        else '0';

    countBits: process(reset, clock)
	begin
		if reset = '1' then
			lrCounter1 <= (others => '1');
			lrCounter <= (others => '1');
		elsif rising_edge(clock) then

            if lrckChanged = '1' then 
                lrCounter1 <= (others => '1');
            elsif sckRising = '1' then 
                lrCounter1 <= lrCounter1 - 1;
            end if ;
            
            if sckFalling = '1' then 
                lrCounter <= lrCounter1 + 1;
            end if ;

        end if;
    end process countBits;

    shiftLrSel: process(reset, clock)
	begin
		if reset = '1' then
			lrSel1 <= '0';
			lrSel <= '0';
		elsif rising_edge(clock) then
            if sckRising = '1' then 
                lrSel1 <= LRCK;
            elsif sckFalling = '1' then 
                lrSel <= lrSel1;
            end if ;
        end if;
    end process shiftLrSel;

    fillReg : process(clock , reset )
    begin
       
        if reset = '1' then
            audioLeft <= (others => '0');
            audioRight <= (others => '0');
		elsif rising_edge(clock) then
            if sckRising = '1' then 
                if lrSel = '1' then 
                    audioLeft(to_integer(lrCounter)) <= DOUT;
                else
                    audioRight(to_integer(lrCounter)) <= DOUT;
                end if;
            end if ; 
        end if;
    end process fillReg;

    lr2 <= lrSel;
  --dataValid <= '1' when  lrCounter = 0 and SCK = '1' and LRCK = '1' else '0';     
    dataValid <= '1' when  lrCounter = 0 and SCK = '1' else '0';         
END ARCHITECTURE MYArchi;
