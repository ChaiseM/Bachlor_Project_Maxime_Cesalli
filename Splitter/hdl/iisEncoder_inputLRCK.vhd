
ARCHITECTURE inputLRCK OF iisEncoder IS
   
   constant frameLength : positive := audioLeft'length;
   constant frameCounterBitNb : positive := requiredBitNb(frameLength - 1);

   signal lrckDelayed, lrckChanged : std_ulogic;
   signal sckDelayed, sckRising, sckFalling : std_ulogic;
   signal frameCounter : unsigned(frameCounterBitNb - 1 downto 0);
   signal frameCounterDelayed : unsigned(frameCounterBitNb - 1 downto 0);
   signal LRDelayed : std_uLogic;
   signal leftShiftRegister : signed(audioLeft'range);
   signal rightShiftRegister : signed(audioRight'range);

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
         frameCounter <= (others => '0');
         frameCounterDelayed <= (others => '0');
         leftShiftRegister <= (others => '0');
         rightShiftRegister <= (others => '0');
         LRDelayed <= '0';
      elsif rising_edge(clock) then
         NewData <= '0';
         if sckRising = '1' then
            -- decrementing frame counter
            frameCounter <= frameCounter - 1;
             -- delaying frameCounter
            frameCounterDelayed <= frameCounter;
            -- delaying LR
            LRDelayed <= LRCK1;
         
         elsif sckFalling = '1' then
          -- updating DOUT at the flaaing edge
            if LRDelayed = '0' then
               DOUT <= leftShiftRegister(to_integer(frameCounterDelayed));
            else
               DOUT <= rightShiftRegister(to_integer(frameCounterDelayed));
            end if;
         end if;

         if lrckChanged = '1' then
            -- reseting the frame counter for every new communication
            frameCounter <= (others => '1');
         end if;
         -- asking for the new data at the msb-2 to delete every posiblity of
         -- transition issues (the 3 lasts bits of every data is '0')      
         if frameCounter = 3 and LRDelayed = '1' and CLKI2s = '0' then
            NewData <= '1';
         end if;
         if frameCounter = 3 and LRDelayed = '1' and CLKI2s = '1' then
            -- saving the values to communicate
            rightShiftRegister <= audioRight;
            leftShiftRegister <= audioLeft;
         end if;
         -- updating the outpout
         LRCK <= LRCK1;
         SCK <= CLKI2s;
         -- debug output
         Frameout0 <= frameCounter(0);
      end if;
   end process FlipFlopAndResize;
   
END ARCHITECTURE inputLRCK;