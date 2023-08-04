
ARCHITECTURE symetrical_reading_SR OF Xover_with_RAM IS
   -- constants
   constant n : positive := 1;
   constant initialWAddress : natural := 0;
   constant initialCoeffAddress : natural := 1501;
   constant HALF_FILTER_TAP_NB : positive := FILTER_TAP_NB/2 +
   (FILTER_TAP_NB mod 2);
   constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
   constant ACCUMULATOR_Bit_NB : positive := COEFF_BIT_NB + audio_In'LENGTH + 
   FINAL_SHIFT;
   constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) +
   initialWAddress) - 1);


   signal debug0 : std_ulogic;
   signal debug1 : std_ulogic;
   signal calculate : std_ulogic; 
   signal calculatedelayed : std_ulogic;
   -- RAM oriented variables ---------------------------------------------------
   signal firstWrite : std_ulogic;
   signal cntNooffset : unsigned(dataBitNb downto 0);
   signal wAddrCnt : unsigned(addressBitNb - 1 downto 0);
   signal coeffAddr : unsigned(addressBitNb - 1 downto 0);
   signal rAddrCnt_Plus : unsigned(addressBitNb - 1 downto 0);
   signal rAddrCnt_Minus : unsigned(addressBitNb - 1 downto 0);
   signal initialRAddress : unsigned(addressBitNb - 1 downto 0);
   signal RAMfull : std_ulogic;
   signal convertsionPoint : std_ulogic;
   signal convertsionPointDelayed : std_ulogic;
   signal sample1L : signed ((audio_In'length/2 )-1 downto 0);
   signal sample1H : signed ((audio_In'length/2 )-1 downto 0);
   signal sample2H : signed ((audio_In'length/2 )-1 downto 0);
   signal sample2L : signed ((audio_In'length/2 )-1 downto 0); 
   signal coeff1L : signed ((audio_In'length/2 )-1 downto 0);
   signal coeff1H : signed ((audio_In'length/2 )-1 downto 0);
   signal coeff2H : signed ((audio_In'length/2 )-1 downto 0);
   signal coeff2L : signed ((audio_In'length/2 )-1 downto 0);
   signal sample1 : signed (audio_In'range);
   signal sample2 : signed (audio_In'range);
   signal HCoeff : signed (audio_In'range);
   signal LCoeff : signed (audio_In'range);
   
   
BEGIN
   shiftSamplesAndMul : process (clock, reset)
      variable AccumulaorHP : signed (ACCUMULATOR_Bit_NB - 1 downto 0);
      variable AccumulaorLP : signed (ACCUMULATOR_Bit_NB - 1 downto 0);
   begin
      if (reset = '1') then
         calculate <=  '0';
         calculatedelayed <= '0';
         wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
         coeffAddr <= to_unsigned(initialCoeffAddress, wAddrCnt'length);
         firstWrite <= '0';
         rdaddr <= (others => '0');
         RAMfull <= '0';
         convertsionPoint <= '0';
         convertsionPointDelayed <= '0';
         cntNooffset <= (others => '0');
      elsif rising_edge(clock)  then
         convertsionPointDelayed <= convertsionPoint;
         writeEnA <= '0';
         we <= '1';
         if newSample = '1' then
            firstWrite <= '1';
            -- writing the samples in the RAM
            if ((wAddrCnt + (2 * n) - initialWAddress)) >= RAMLength then
               initialRAddress <= to_unsigned(initialWAddress, initialRAddress'length);
            else
               initialRAddress <= ((wAddrCnt + (2 * n) - initialWAddress));
            end if;
            wAddrCnt <= wAddrCnt + n;
            writeEnA <= '1';
            din <= std_ulogic_vector(unsigned(audio_In(audio_In'LENGTH - 1 downto (audio_In'LENGTH - (audio_In'length/2)))));
            wraddr <= std_ulogic_vector(wAddrCnt);
         end if;
         if firstWrite = '1' then
            calculate <= '1';
            cntNooffset <= (others => '0');
            firstWrite <= '0';
            wAddrCnt <= wAddrCnt + n;
            rAddrCnt_Plus <= initialRAddress;
            rAddrCnt_Minus <= initialRAddress-1;
            wraddr <= std_ulogic_vector(initialRAddress);
            if wAddrCnt >= RAMLength then
               RAMfull <= '1';
               wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
            end if;
            writeEnA <= '1';
            din <= std_ulogic_vector(unsigned(audio_In((audio_In'LENGTH - (audio_In'length/2) - 1) downto 0)));
            wraddr <= std_ulogic_vector(wAddrCnt);
         end if;
         calculatedelayed <= calculate;
        
         coeffAddr <= to_unsigned(initialCoeffAddress, coeffAddr'length);


         if calculatedelayed = '1' and RAMfull = '1' then
            re <= '0';
          
            if convertsionPointDelayed = '1' then
            
               -- updating the Highpass and Lowpass outpout
               Highpass <= resize(shift_right(AccumulaorHP, ACCUMULATOR_Bit_NB - 
               Highpass'LENGTH - 10), Highpass'length);
               LowPass<= resize(shift_right(AccumulaorLP, ACCUMULATOR_Bit_NB -
               LowPass'LENGTH - 10), LowPass'length);
            
            
               -- reseting everything 
               convertsionPoint <= '0';
               convertsionPointDelayed <= '0';
               calculate <= '0';
               coeffAddr <= to_unsigned(initialCoeffAddress, coeffAddr'length);
               cntNooffset <= (others => '0');
               AccumulaorHP := (others => '0');
               AccumulaorLP := (others => '0');
               
               
            else
               cntNooffset <= cntNooffset + 1;
            end if;
            
            -- coeff adress update and incement 
            rdaddr <= std_ulogic_vector(coeffAddr);
            coeffAddr <= coeffAddr + 1;
           
           
            debug0 <= '0';
            debug1 <= '0';
            
            if cntNooffset mod 4 = 0 then 
               debug0 <= '1';
               -- creating the full data with the concateanation of 2 RAM data
               sample2(sample2'LENGTH - 1 downto (sample2'LENGTH - (sample2'length/2))) <= sample2H;
               sample2((sample2'LENGTH - (sample2'length/2) - 1) downto 0) <= sample2L;
               
               -- positive sample adress upodate and incement
               wraddr <= std_ulogic_vector(rAddrCnt_Plus);
               rAddrCnt_Plus <= rAddrCnt_Plus + 1;
               
               -- saving the RAM value to create the full data 
               sample1L <= signed(dout1);
               coeff1L <=  signed(DataInCoeffs); 
            elsif cntNooffset mod 4 = 1 then 
               debug0 <= '1';
               -- creating the full data with the concateanation of 2 RAM data
               HCoeff(HCoeff'LENGTH - 1 downto (HCoeff'LENGTH - (HCoeff'length/2))) <= coeff1H;
               HCoeff((HCoeff'LENGTH - (HCoeff'length/2) - 1) downto 0) <= coeff1L;
               
               -- positive sample adress upodate and incement
               wraddr <= std_ulogic_vector(rAddrCnt_Plus);
               rAddrCnt_Plus <= rAddrCnt_Plus + 1;
               
               -- saving the RAM value to create the full data 
               sample1H <= signed(dout1);
               coeff2H <=  signed(DataInCoeffs);
            elsif cntNooffset mod 4 = 2 then 
               debug1 <= '1';
               -- creating the full data with the concateanation of 2 RAM data
               sample1(sample1'LENGTH - 1 downto (sample1'LENGTH - (sample1'length/2))) <= sample1H;
               sample1((sample1'LENGTH - (sample1'length/2) - 1) downto 0) <= sample1L;
               
               -- negative sample adress upodate and incement
               wraddr <= std_ulogic_vector(rAddrCnt_Minus);
               rAddrCnt_Minus <= rAddrCnt_Minus - 1;
               
               -- saving the RAM value to create the full data 
               sample2H <= signed(dout1);
               coeff2L <=  signed(DataInCoeffs);
            elsif cntNooffset mod 4 = 3 then 
               debug1 <= '1';
               -- creating the full data with the concateanation of 2 RAM data
               LCoeff(LCoeff'LENGTH - 1 downto (LCoeff'LENGTH - (LCoeff'length/2))) <= coeff2H;
               LCoeff((LCoeff'LENGTH - (LCoeff'length/2) - 1) downto 0) <= coeff2L;
              
               -- negative sample adress upodate and incement
               wraddr <= std_ulogic_vector(rAddrCnt_Minus);
               rAddrCnt_Minus <= rAddrCnt_Minus - 1;
               
               -- saving the RAM value to create the full data 
               coeff1H <=  signed(DataInCoeffs);
               sample2L <= signed(dout1);
            end if;
            -- if we go past the ram length we need 
            if rAddrCnt_Plus >= RAMLength then
               -- reset the counter to intial adress
               rAddrCnt_Plus <= to_unsigned(initialWAddress, wAddrCnt'length);
            end if;
            -- if we go past the ram length we need 
            if rAddrCnt_Minus-1 > RAMLength then
               -- reset the counter to the final adress
              
               rAddrCnt_Minus <= to_unsigned(RAMLength, rAddrCnt_Plus'length);
            end if;
          
            
            -- if the conversion point is reached 
            if cntNooffset = (FILTER_TAP_NB * n * 2 ) + 5 then
               convertsionPoint <= '1';
               -- updates the accumulator with only one sample because
               -- sample1 = sample2 at the conversion Point 
               AccumulaorHP := AccumulaorHP + sample1 * HCoeff;
               AccumulaorLP := AccumulaorLP + sample1 * LCoeff;
            elsif cntNooffset >= 7 and (cntNooffset mod 4) = 0 
            and cntNooffset <= (FILTER_TAP_NB * n * 2 )+ 3 then
               -- updates the accumulators
               AccumulaorHP := AccumulaorHP + (resize(sample1, sample1'LENGTH + 1) + sample2) * HCoeff;
               AccumulaorLP := AccumulaorLP + (resize(sample1, sample1'LENGTH + 1) + sample2) * LCoeff;
            end if;

         end if;
      end if;
   end process shiftSamplesAndMul;
   
   DataReady <= '1' when calculate = '0' else '0';
   DebugData(1) <= convertsionPoint;
   DebugData(0) <= newSample;
   
END ARCHITECTURE symetrical_reading_SR;