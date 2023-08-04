--
-- VHDL Architecture Splitter.testerRS232.RS232_test1
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 09:43:22 02.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

ARCHITECTURE RS232_test1 OF testerRS232 IS
   signal debuggg : std_ulogic;
   
   signal isA, isB, isC, isD, isE, isF, isG, isH,
         isI, isJ, isK, isL, isM, isN, isO, isP,
         isQ, isR, isS, isT, isU, isV, isW, isX,
         isY, isZ,
         is0, is1, is2, is3, is4, is5, is6, is7,
         is8, is9, 
         isSpace,isExcla,isHashTag : std_ulogic;
   TYPE STATEL_TYPE IS (           --State enum for SM LEFT
    
      state_idle,
      state_test0,
      state_test1,
      state_test2,
      state_coeffNb,
      state_startCoeff,
      state_newCoeff
      
  );
  
  signal cnt : unsigned(7 downto 0);
  signal cnt1 : unsigned(7 downto 0);
  signal coeffCnt : unsigned(31 downto 0);
  signal currentState : STATEL_TYPE;
  signal temp0 : unsigned(3 downto 0);
  signal coeff0 : unsigned(31 downto 0);
  signal temp1 : unsigned(3 downto 0);
  signal coeffNb : unsigned(31 downto 0);
  signal outputEnDriver : std_ulogic;
BEGIN

    ------------------------------------------------------------------------------
                                                   -- conditions for morse units
  isA <= '1' when std_match(unsigned(RS232Data), "1-0" & x"1") else '0';
  isB <= '1' when std_match(unsigned(RS232Data), "1-0" & x"2") else '0';
  isC <= '1' when std_match(unsigned(RS232Data), "1-0" & x"3") else '0';
  isD <= '1' when std_match(unsigned(RS232Data), "1-0" & x"4") else '0';
  isE <= '1' when std_match(unsigned(RS232Data), "1-0" & x"5") else '0';
  isF <= '1' when std_match(unsigned(RS232Data), "1-0" & x"6") else '0';
  isG <= '1' when std_match(unsigned(RS232Data), "1-0" & x"7") else '0';
  isH <= '1' when std_match(unsigned(RS232Data), "1-0" & x"8") else '0';
  isI <= '1' when std_match(unsigned(RS232Data), "1-0" & x"9") else '0';
  isJ <= '1' when std_match(unsigned(RS232Data), "1-0" & x"A") else '0';
  isK <= '1' when std_match(unsigned(RS232Data), "1-0" & x"B") else '0';
  isL <= '1' when std_match(unsigned(RS232Data), "1-0" & x"C") else '0';
  isM <= '1' when std_match(unsigned(RS232Data), "1-0" & x"D") else '0';
  isN <= '1' when std_match(unsigned(RS232Data), "1-0" & x"E") else '0';
  isO <= '1' when std_match(unsigned(RS232Data), "1-0" & x"F") else '0';
  isP <= '1' when std_match(unsigned(RS232Data), "1-1" & x"0") else '0';
  isQ <= '1' when std_match(unsigned(RS232Data), "1-1" & x"1") else '0';
  isR <= '1' when std_match(unsigned(RS232Data), "1-1" & x"2") else '0';
  isS <= '1' when std_match(unsigned(RS232Data), "1-1" & x"3") else '0';
  isT <= '1' when std_match(unsigned(RS232Data), "1-1" & x"4") else '0';
  isU <= '1' when std_match(unsigned(RS232Data), "1-1" & x"5") else '0';
  isV <= '1' when std_match(unsigned(RS232Data), "1-1" & x"6") else '0';
  isW <= '1' when std_match(unsigned(RS232Data), "1-1" & x"7") else '0';
  isX <= '1' when std_match(unsigned(RS232Data), "1-1" & x"8") else '0';
  isY <= '1' when std_match(unsigned(RS232Data), "1-1" & x"9") else '0';
  isZ <= '1' when std_match(unsigned(RS232Data), "1-1" & x"A") else '0';
  is0 <= '1' when std_match(unsigned(RS232Data), "011" & x"0") else '0';
  is1 <= '1' when std_match(unsigned(RS232Data), "011" & x"1") else '0';
  is2 <= '1' when std_match(unsigned(RS232Data), "011" & x"2") else '0';
  is3 <= '1' when std_match(unsigned(RS232Data), "011" & x"3") else '0';
  is4 <= '1' when std_match(unsigned(RS232Data), "011" & x"4") else '0';
  is5 <= '1' when std_match(unsigned(RS232Data), "011" & x"5") else '0';
  is6 <= '1' when std_match(unsigned(RS232Data), "011" & x"6") else '0';
  is7 <= '1' when std_match(unsigned(RS232Data), "011" & x"7") else '0';
  is8 <= '1' when std_match(unsigned(RS232Data), "011" & x"8") else '0';
  is9 <= '1' when std_match(unsigned(RS232Data), "011" & x"9") else '0';
  isSpace <= '1' when std_match(unsigned(RS232Data), "010" & x"0") else '0';
  isExcla <= '1' when std_match(unsigned(RS232Data), "010" & x"1") else '0';
  isHashTag <= '1' when std_match(unsigned(RS232Data), "010" & x"3") else '0';
  
    
   
   testter : process(clock,reset)
   begin 
      if reset = '1' then
       
         currentState <= state_idle;
         cnt <= (others => '0');
         cnt1 <= (others => '0');
         Coeffcnt <= (others => '0');
         coeff0 <= (others => '0');
         coeffNb <= (others => '0');
         filterTapNb <= FILTER_TAP_NB;
         outputEn <= '0';
      elsif rising_edge(clock) then
         newCoeff <= '0';
       
         if RS232Valid = '1' then 
            -- Idle State 
            if currentState = state_idle and isN = '1' then 
               currentState <= state_test0;
            end if;
            
            if currentState = state_test0 and isE = '1' then 
               currentState <= state_test1;
            end if;
            if currentState = state_test1 and isW = '1' then 
               currentState <= state_CoeffNb;
               cnt1 <= (others => '0');
               coeffCnt <= (others => '0');
            end if;
            if currentState = state_CoeffNb then 
               
               cnt1 <= cnt1 + 1;
               if is0  = '1'     then temp1 <= to_unsigned(0,temp1'length);
               elsif is1 = '1'   then temp1 <= to_unsigned(1,temp1'length);
               elsif is2 = '1'   then temp1 <= to_unsigned(2,temp1'length);
               elsif is3 = '1'   then temp1 <= to_unsigned(3,temp1'length);
               elsif is4 = '1'   then temp1 <= to_unsigned(4,temp1'length);
               elsif is5 = '1'   then temp1 <= to_unsigned(5,temp1'length);
               elsif is6 = '1'   then temp1 <= to_unsigned(6,temp1'length);
               elsif is7 = '1'   then temp1 <= to_unsigned(7,temp1'length);
               elsif is8  = '1'  then temp1 <= to_unsigned(8,temp1'length); 
               elsif is9 = '1'   then temp1 <= to_unsigned(9,temp1'length);
               elsif isA = '1'   then temp1 <= to_unsigned(10,temp1'length);
               elsif isB = '1'   then temp1 <= to_unsigned(11,temp1'length);
               elsif isC = '1'   then temp1 <= to_unsigned(12,temp1'length);
               elsif isD = '1'   then temp1 <= to_unsigned(13,temp1'length);
               elsif isE = '1'   then temp1 <= to_unsigned(14,temp1'length);
               elsif isF = '1'   then temp1 <= to_unsigned(15,temp1'length);
               -- condition to do out of the newCoeff state 
               elsif isHashTag = '1'  then 
                  currentState <= state_startCoeff;
                  outputEnDriver <= not outputEnDriver;
               end if;
               
               
               
               if cnt1 /= 0 and cnt1 <=4 then 
                 
                  if cnt1 = 1 then coeffNb(15 downto 12) <= temp1;
                  elsif cnt1 = 2 then coeffNb(11 downto 8) <= temp1;
                  elsif cnt1 = 3 then coeffNb(7 downto 4) <= temp1;
                  elsif cnt1 = 4 then coeffNb(3 downto 0) <= temp1;
                  end if;
                  -- coeff0(to_integer((8-(cnt-1)*4)-1) downto 
                  -- to_integer((8-cnt)*4)) <= temp0;
               end if; 
            end if;
         
            
            if currentState = state_startCoeff and isX = '1' then 
               
               if coeffcnt > coeffNb then
                  currentState <= state_idle;
                  coeffCnt <= (others => '0');
               else
                  if coeffCnt /= 0 then 
                     RS232Coeff <= signed(coeff0); 
                     newCoeff <= '1';
                  end if;
                  currentState <= state_test2;
               end if;
              
            end if;
            -- test if we are reciving a new coefff
            if currentState = state_test2 and isExcla = '1' then
               currentState <= state_newCoeff;
               coeffCnt <= coeffCnt + 1;
               cnt <= (others => '0');
            end if;
            -- translating ascii values to hex(32 bits)
            if currentState = state_newCoeff then 
               
               cnt <= cnt + 1;
               if is0  = '1'     then temp0 <= to_unsigned(0,temp0'length);
               elsif is1 = '1'   then temp0 <= to_unsigned(1,temp0'length);
               elsif is2 = '1'   then temp0 <= to_unsigned(2,temp0'length);
               elsif is3 = '1'   then temp0 <= to_unsigned(3,temp0'length);
               elsif is4 = '1'   then temp0 <= to_unsigned(4,temp0'length);
               elsif is5 = '1'   then temp0 <= to_unsigned(5,temp0'length);
               elsif is6 = '1'   then temp0 <= to_unsigned(6,temp0'length);
               elsif is7 = '1'   then temp0 <= to_unsigned(7,temp0'length);
               elsif is8  = '1'  then temp0 <= to_unsigned(8,temp0'length); 
               elsif is9 = '1'   then temp0 <= to_unsigned(9,temp0'length);
               elsif isA = '1'   then temp0 <= to_unsigned(10,temp0'length);
               elsif isB = '1'   then temp0 <= to_unsigned(11,temp0'length);
               elsif isC = '1'   then temp0 <= to_unsigned(12,temp0'length);
               elsif isD = '1'   then temp0 <= to_unsigned(13,temp0'length);
               elsif isE = '1'   then temp0 <= to_unsigned(14,temp0'length);
               elsif isF = '1'   then temp0 <= to_unsigned(15,temp0'length);
               -- condition to do out of the newCoeff state 
               elsif isExcla = '1'  then 
                  currentState <= state_startCoeff;
                  outputEnDriver <= not outputEnDriver;
               end if;
               
               
               if cnt /= 0 and cnt <=8 then 
                 
                  
                  if cnt = 1 then coeff0(31 downto 28) <= temp0;
                  elsif cnt = 2 then coeff0(27 downto 24) <= temp0;
                  elsif cnt = 3 then coeff0(23 downto 20) <= temp0;
                  elsif cnt = 4 then coeff0(19 downto 16) <= temp0;
                  elsif cnt = 5 then coeff0(15 downto 12) <= temp0;
                  elsif cnt = 6 then coeff0(11 downto 8) <= temp0;
                  elsif cnt = 7 then coeff0(7 downto 4) <= temp0;
                  elsif cnt = 8 then coeff0(3 downto 0) <= temp0;
                  end if;
                  
                  -- coeff0(to_integer((8-(cnt-1)*4)-1) downto 
                  -- to_integer((8-cnt)*4)) <= temp0;
               end if; 
            end if;
         end if;  
         
         outputEn <= outputEnDriver;
         
      end if; 
   end process testter;

END ARCHITECTURE RS232_test1;

