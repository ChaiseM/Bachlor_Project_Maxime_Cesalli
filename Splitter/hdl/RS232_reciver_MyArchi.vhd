--
-- VHDL Architecture Splitter.RS232_reciver.MyArchi
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 16:57:12 15.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

library Common;
use Common.CommonLib.all;

ARCHITECTURE MyArchi OF RS232_reciver IS
   signal rxDelayed : std_ulogic; 
   signal rxDelayed1 : std_ulogic;
   signal rxDelayed2 : std_ulogic;
   signal rxDelayed3 : std_ulogic;
   signal rxFalling : std_ulogic ;
   
   TYPE STATE_TYPE IS (           --State enum for SM LEFT

      state_idle,
      state_startCnt,
      state_readData
  );
   signal cnt : unsigned(requiredBitNb(baudRateDivide-1)-1 downto 0);
   signal cnt2 : signed(requiredBitNb(uartDataBitNb-1) downto 0);
   signal RS232Register : std_ulogic_vector(uartDataBitNb-1 downto 0);
   signal currentState : STATE_TYPE;
BEGIN

   ShiftRX : process(clock,reset)
   begin
      if reset = '1' then
         rxDelayed <= '0';
      elsif rising_edge(clock) then
         rxDelayed <= RxD;
         degug01 <= rxDelayed;
         rxDelayed1 <= rxDelayed;
         rxDelayed2 <= rxDelayed1;
         rxDelayed3 <= rxDelayed2;
         degug01 <= rxDelayed3;
      end if;
   end process ShiftRX;
   
   
   rxFalling <=   '1' when (RxD = '0' and rxDelayed3 = '1' 
                  and currentState = state_idle) else '0';

   
   StateMachine : process(clock,reset)
   begin  
      if reset = '1' then 
         cnt <= (others => '0');
         cnt2 <= (others => '0');
         currentState <= state_idle;
         RS232Register <= (others => '0');
      elsif rising_edge(clock) then
         debug0 <= '0';
         RS232Valid <= '0';
         if currentState = state_idle then 
            if rxFalling = '1' then 
               currentState <= state_startCnt;
            end if;
         end if;
         
         if currentState = state_startCnt then 
            cnt <= cnt + 1;
            if cnt = baudRateDivide/2 then 
               currentState <= state_readData;
               cnt <= (others => '0');
               cnt2 <= (others => '0');   
            end if;
         end if;
         
         if currentState = state_readData then 
            debug0 <= '1';
            cnt <= cnt + 1;
              
               if cnt = (baudRateDivide+150) then 
                  if cnt2 = uartDataBitNb then
                     cnt <= (others => '0');
                     RS232Data <= RS232Register;
                     RS232Valid <= '1';
                     currentState <= state_idle;
                  else
                     cnt2 <= cnt2+1;
                     cnt <= (others => '0');
                     RS232Register(to_integer(cnt2)) <= RxD;
                  end if;
               end if;
         
         end if;
         
         
      end if;
   
   
   end process StateMachine;
   
   

END ARCHITECTURE MyArchi;

