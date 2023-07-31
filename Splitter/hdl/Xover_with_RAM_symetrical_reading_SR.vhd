
ARCHITECTURE symetrical_reading_SR OF Xover_with_RAM IS
   -- constants
   constant n : positive := 1;
   constant initialWAddress : natural := 0;
   constant initialCoeffAddress : natural := 1023;
   constant HALF_FILTER_TAP_NB : positive := FILTER_TAP_NB/2 +
   (FILTER_TAP_NB mod 2);
   constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
   constant ACCUMULATOR_Bit_NB : positive := COEFF_BIT_NB + audio_In'LENGTH + 
   FINAL_SHIFT;
   constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) +
   initialWAddress) - 1);


   signal debug : signed(ACCUMULATOR_Bit_NB - 1 downto 0);
   signal oldLRCK : std_ulogic;
   signal calculate : unsigned (2 downto 0);
   signal calculatedelayed : unsigned (2 downto 0);
   signal cnt : unsigned(FINAL_SHIFT - 1 downto 0);
   signal cnt2 : unsigned (2 downto 0);
   signal sum_v : signed(audio_In'LENGTH downto 0) := (others => '0');
   signal mul_v1 : signed(audio_In'LENGTH + COEFF_BIT_NB downto 0) := (others => '0');
   signal mul_v2 : signed(audio_In'LENGTH + COEFF_BIT_NB downto 0) := (others => '0');
   signal selector : unsigned (2 downto 0);
   --signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
   -- RAM oriented variables ----------------------------------------------------
   signal firstWrite : std_ulogic;
   signal cntNooffset : unsigned(dataBitNb downto 0);
   signal firstRead : unsigned(3 downto 0);
   signal wAddrCnt : unsigned(addressBitNb - 1 downto 0);
   signal coeffAddr : unsigned(addressBitNb - 1 downto 0);
   signal rAddrCnt_Plus : unsigned(addressBitNb - 1 downto 0);
   signal rAddrCnt_Minus : unsigned(addressBitNb - 1 downto 0);
   signal initialRAddress : unsigned(addressBitNb - 1 downto 0);
   signal RAMfull : std_ulogic;
   signal convertsionPoint : std_ulogic;
   signal convertsionPointDelayed : std_ulogic;
   signal lastSampleOK : std_ulogic;
   signal RAMfulldelayed : std_ulogic;
   signal temp1 : signed (audio_In'range);
   signal temp2 : signed (audio_In'range);
   signal temp3 : signed (audio_In'range);
   signal temp4 : signed (audio_In'range);
   signal temp5 : signed (audio_In'range);
   signal temp6 : signed (audio_In'range);
   signal sample1 : signed (audio_In'range);
   signal sample2 : signed (audio_In'range);
   signal coeff1 : signed (audio_In'range);
   signal coeff2 : signed (audio_In'range);
   signal sample2en : std_ulogic;
   
   -- array
   -- vector of FILTER_TAP_NB signed elements
   type t_samples is array (0 to FILTER_TAP_NB - 1) of signed (audio_In'range); 
   signal samples : t_samples;

BEGIN
   shiftSamplesAndMul : process (clock, reset)
      variable accumulator1 : signed (ACCUMULATOR_Bit_NB - 1 downto 0);
      variable accumulator2 : signed (ACCUMULATOR_Bit_NB - 1 downto 0);
   begin
      if (reset = '1') then
         samples <= (others => (others => '0'));
         cnt <= (others => '0');
         cnt2 <= (others => '0');
         calculate <= (others => '0');
         calculatedelayed <= (others => '0');
         oldLRCK <= '0';
         selector <= (others => '0');
         wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
         coeffAddr <= to_unsigned(initialCoeffAddress, wAddrCnt'length);
         firstWrite <= '0';
         firstRead <= (others => '0');
         rdaddr <= (others => '0');
         RAMfull <= '0';
         convertsionPoint <= '0';
         convertsionPointDelayed <= '0';
         lastSampleOK <= '0';
         RAMfulldelayed <= '0';
         cntNooffset <= (others => '0');
      elsif rising_edge(clock) then
         convertsionPointDelayed <= convertsionPoint;
         writeEnA <= '0';
         we <= '1';
         if en = '1' then
            firstWrite <= '1';
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
            calculate <= to_unsigned(1, calculate'length);
            cntNooffset <= (others => '0');
            firstWrite <= '0';
            wAddrCnt <= wAddrCnt + n;
            rAddrCnt_Plus <= initialRAddress;
            rAddrCnt_Minus <= initialRAddress;
            wraddr <= std_ulogic_vector(initialRAddress);
            if wAddrCnt >= RAMLength then
               RAMfull <= '1';
               wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
            end if;
            RAMfulldelayed <= RAMfull;
            writeEnA <= '1';
            din <= std_ulogic_vector(unsigned(audio_In((audio_In'LENGTH - (audio_In'length/2) - 1) downto 0)));
            wraddr <= std_ulogic_vector(wAddrCnt);
         end if;
         calculatedelayed <= calculate;
        
         coeffAddr <= to_unsigned(initialCoeffAddress, coeffAddr'length);


         if calculatedelayed > 0 and RAMfull = '1' then
            re <= '0';
            if cntNooffset < 9 then
               sample1 <= (others => '0');
               sample2 <= (others => '0');
               cnt <= (others => '0');
            end if;
            if convertsionPointDelayed = '1' then
               convertsionPoint <= '0';
               convertsionPointDelayed <= '0';
               calculate <= calculate - 1;
               coeffAddr <= to_unsigned(initialCoeffAddress, coeffAddr'length);
               cntNooffset <= (others => '0');
               lowPass <= resize(shift_right(accumulator1, ACCUMULATOR_Bit_NB - Lowpass'LENGTH - 9), Lowpass'length);
               Highpass <= resize(shift_right(accumulator2, ACCUMULATOR_Bit_NB - Lowpass'LENGTH - 9), Lowpass'length);
               cnt <= (others => '0');
               accumulator1 := (others => '0');
               accumulator2 := (others => '0');

            else
               cntNooffset <= cntNooffset + 1;
            end if;

            -------------------------------------------------------------
            --                         1                               --
            -------------------------------------------------------------

            if (rAddrCnt_Plus mod 2) = 0 and (cntNooffset mod 4) = 0 then
               -- coeff adress update and incement 
               rdaddr <= std_ulogic_vector(coeffAddr);
               coeffAddr <= coeffAddr + 1;
               -- positive sample adress upodate and incement
               wraddr <= std_ulogic_vector(abs(signed(rAddrCnt_Plus)-2));
               rAddrCnt_Plus <= rAddrCnt_Plus + 1;
               
               temp3(temp3'LENGTH - 1 downto (temp3'LENGTH - (temp3'length/2))) <= signed(DataInCoeffs);
               temp1((temp1'LENGTH - (temp1'length/2) - 1) downto 0) <= signed(dout1);
               
               sample1 <= temp1;
            end if;
             -------------------------------------------------------------
            --                         2                               --
            -------------------------------------------------------------
            if (rAddrCnt_Plus mod 2) = 1 and (cntNooffset mod 4) = 1 then
                -- coeff adress update and incement 
               rdaddr <= std_ulogic_vector(coeffAddr);
               coeffAddr <= coeffAddr + 1;
               -- positive sample adress upodate and incement
               wraddr <= std_ulogic_vector(abs(signed(rAddrCnt_Plus)-2));
               rAddrCnt_Plus <= rAddrCnt_Plus + 1;
 
               temp3((temp3'LENGTH - (temp3'length/2) - 1) downto 0) <= signed(DataInCoeffs);
               temp1(temp1'LENGTH - 1 downto (temp1'LENGTH - (temp1'length/2))) <= signed(dout1);
               
               coeff2 <= temp4;
            end if;
             -------------------------------------------------------------
            --                         3                               --
            -------------------------------------------------------------
            if (rAddrCnt_Minus mod 2) = 1 and (cntNooffset mod 4) = 2 then
               -- coeff adress update and incement 
               rdaddr <= std_ulogic_vector(coeffAddr);
               coeffAddr <= coeffAddr + 1;
               -- negative sample adress upodate and incement
               wraddr <= std_ulogic_vector(rAddrCnt_Minus);
               rAddrCnt_Minus <= rAddrCnt_Minus - 1;
               
               temp4(temp4'LENGTH - 1 downto (temp4'LENGTH - (temp4'length/2))) <= signed(DataInCoeffs);
               temp2(temp2'LENGTH - 1 downto (temp2'LENGTH - (temp2'length/2))) <= signed(dout1);
               
               sample2 <= temp2;
            end if;
             -------------------------------------------------------------
            --                         4                               --
            -------------------------------------------------------------
            if (rAddrCnt_Minus mod 2) = 0 and (cntNooffset mod 4) = 3 then
                -- coeff adress update and incement 
               rdaddr <= std_ulogic_vector(coeffAddr);
               coeffAddr <= coeffAddr + 1;
               -- negative sample adress upodate and incement
               wraddr <= std_ulogic_vector(rAddrCnt_Minus);
               rAddrCnt_Minus <= rAddrCnt_Minus - 1;
               
               temp4((temp4'LENGTH - (temp4'length/2) - 1) downto 0) <= signed(DataInCoeffs);
               temp2((temp2'LENGTH - (temp2'length/2) - 1) downto 0) <= signed(dout1);
               
               if coeffAddr <= RAMLength + initialCoeffAddress + 8 then
                  coeff1 <= temp3;
               else
                  coeff1 <= coeff1;
               end if;
               
            end if;


            if rAddrCnt_Plus >= RAMLength then
               rAddrCnt_Plus <= to_unsigned(initialWAddress, wAddrCnt'length);
            end if;

            if rAddrCnt_Minus > RAMLength then
               rAddrCnt_Minus <= to_unsigned(RAMLength, rAddrCnt_Plus'length);
            end if;
            if cntNooffset = (FILTER_TAP_NB * n * 2 ) + 11 then
                  convertsionPoint <= '1';
                  accumulator1 := accumulator1 + sample1 * coeff1;
                  accumulator2 := accumulator2 + sample1 * coeff2;
            elsif cntNooffset >= 12 and (cntNooffset mod 4) = 1 and cnt <= HALF_FILTER_TAP_NB - 2 then
               cnt <= cnt + 1;
               accumulator1 := accumulator1 + (resize(sample1, sample1'LENGTH + 1) + sample2) * coeff1;
               accumulator2 := accumulator2 + (resize(sample1, sample1'LENGTH + 1) + sample2) * coeff2;
            end if;

         end if;
      end if;
   end process shiftSamplesAndMul;
   DataReady <= '1' when calculate = 0 else '0';
   DebugData(1) <= '0';
   DebugData(0) <= '0';
END ARCHITECTURE symetrical_reading_SR;