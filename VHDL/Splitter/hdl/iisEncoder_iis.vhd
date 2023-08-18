ARCHITECTURE iis OF iisEncoder IS
   -- constants
   constant frameLength : positive := audioLeft'length;
   constant frameCounterBitNb : positive := requiredBitNb(frameLength - 1);
   -- signals 
   signal lrckDelayed, lrckChanged : std_ulogic;
   signal sckDelayed, sckRising, sckFalling : std_ulogic;
   signal LR : std_uLogic;
   signal LRDelayed : std_uLogic;
   signal tempR : signed(audioRight'range);
   signal tempL : signed(audioLeft'range);
   signal tempCnt : unsigned(10 downto 0);
   signal frameCounter : unsigned(frameCounterBitNb - 1 downto 0);
   signal frameCounterDelayed : unsigned(frameCounterBitNb - 1 downto 0);
  

BEGIN

   delaySck : process (reset, clock)
   begin
      if reset = '1' then
         sckDelayed <= '0';
         lrckDelayed <= '0';
      elsif rising_edge(clock) then
         -- 1 clock period delay to detect the edges
         sckDelayed <= CLKI2s;
         lrckDelayed <= LRCK1;
      end if;
   end process delaySck;
    -- edges detection
   sckRising <= '1' when (CLKI2s = '1') and (sckDelayed = '0') else '0';
   sckFalling <= '1' when (CLKI2s = '0') and (sckDelayed = '1') else '0';
   lrckChanged <= '1' when LRCK1 /= lrckDelayed else '0';
   
   FlipFlopAndResize : process (reset, clock)
   begin
      if reset = '1' then
         frameCounter <= (others => '1');
         leftShiftRegister <= (others => '0');
         LRDelayed <= '0';
         rightShiftRegister <= (others => '0');
         LR <= '0';
      elsif rising_edge(clock) then
         NewData <= '0';
         
         if sckRising = '1' then
            -- saving the values to communicate
            if frameCounter = 1 and LR = '0' then
               tempL <= audioLeft;
               tempR <= audioRight;
            end if;
         end if;
         if sckFalling = '1' then
            -- delaying LR
            LRDelayed <= LR;
            frameCounter <= frameCounter - 1;
            -- delaying frameCounter
            frameCounterDelayed <= frameCounter;
            if frameCounter = 1 and LR = '0' then
               -- indicating to the prevouis block : ready to transmit new data
               NewData <= '1';
            end if;
            if frameCounter = 0 then
               -- once one word is fully transmited toggles LR
               LR <= not LR;
            end if;
         end if;

         -- updating the outputs 
         LRCK <= LR;
         SCK <= CLKI2s;
         -- selecting the bits to transmitt with 
         --LRDelayed and frameCounterDelayed
         if LRDelayed = '1' then
            DOUT <= tempL(to_integer(frameCounterDelayed));
         else
            DOUT <= tempR(to_integer(frameCounterDelayed));
         end if;
      end if;
   end process FlipFlopAndResize;
   
   Frameout0 <= frameCounterDelayed(0);
   
END ARCHITECTURE iis;