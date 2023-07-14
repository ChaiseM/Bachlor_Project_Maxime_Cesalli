--
-- VHDL Architecture Splitter.Xover_with_RAM.FirstArchi
--
-- Created:
--          by - maxim.UNKNOWN (DESKTOP-ADLE19A)
--          at - 12:11:17 12/07/2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE FirstArchi OF Xover_with_RAM IS
 constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audio_In'length + FINAL_SHIFT  ;  
   
   
    signal debug :signed(ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    -- +1 because it is symetrical we add two samples together
   
    type   t_samples is array (0 to FILTER_TAP_NB-1) of signed (audio_In'range);  -- vector of FILTER_TAP_NB signed elements
    signal samples : t_samples ; 
    signal oldLRCK : std_ulogic;
    
    signal calculate  : unsigned (2 downto 0);
    signal calculatedelayed  : unsigned (2 downto 0);
    signal cnt   : unsigned(FINAL_SHIFT-1 DOWNTO 0);
    signal cnt2 :  unsigned (2 downto 0);
    signal sum_v : signed(audio_In'length downto 0) := (others=>'0');
    signal mul_v1 : signed(audio_In'length+COEFF_BIT_NB downto 0) := (others=>'0');
    signal mul_v2: signed(audio_In'length+COEFF_BIT_NB downto 0) := (others=>'0');
    signal selector :unsigned (2 downto 0);
    --signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
-- RAM oriented variables ----------------------------------------------------
    signal firstWrite : std_ulogic;
    signal cntNooffset :  unsigned(15 downto 0);
    signal firstRead :  unsigned(3 downto 0);
    signal wAddrCnt : unsigned(15 downto 0);
    signal rAddrCnt_Plus : unsigned(15 downto 0);
    signal rAddrCnt_Minus : unsigned(15 downto 0);
    signal initialRAddress : unsigned(15 downto 0);
    signal RAMfull : std_ulogic;
    signal RAMfulldelayed : std_ulogic;
    constant n: positive := 1 ;     
    constant initialWAddress : natural := 0;
    signal temp1 :  signed (audio_In'range); 
    signal sample1 :  signed (audio_In'range);
    constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) + initialWAddress) -1);     
    
    -- lowpass firtst then highpass coeff
    type coefficients is array (0 to 1,0 to FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=(
    ( 
        x"FFFF", x"0000", x"0000", x"0000", x"0000", x"0000", 
        x"0001", x"0001", x"0001", x"0001", x"0000", x"FFFF", 
        x"FFFD", x"FFF9", x"FFF5", x"FFF0", x"FFEC", x"FFEA", 
        x"FFEC", x"FFF2", x"FFFD", x"000E", x"0025", x"003F", 
        x"0059", x"006F", x"007C", x"0079", x"0063", x"0035", 
        x"FFF1", x"FF97", x"FF30", x"FEC5", x"FE67", x"FE27", 
        x"FE15", x"FE44", x"FEC1", x"FF94", x"00BC", x"0234", 
        x"03EC", x"05CA", x"07B0", x"097E", x"0B11", x"0C4A", 
        x"0D11", x"0D55", x"0D11", x"0C4A", x"0B11", x"097E", 
        x"07B0", x"05CA", x"03EC", x"0234", x"00BC", x"FF94", 
        x"FEC1", x"FE44", x"FE15", x"FE27", x"FE67", x"FEC5", 
        x"FF30", x"FF97", x"FFF1", x"0035", x"0063", x"0079", 
        x"007C", x"006F", x"0059", x"003F", x"0025", x"000E", 
        x"FFFD", x"FFF2", x"FFEC", x"FFEA", x"FFEC", x"FFF0", 
        x"FFF5", x"FFF9", x"FFFD", x"FFFF", x"0000", x"0001", 
        x"0001", x"0001", x"0001", x"0000", x"0000", x"0000", 
        x"0000", x"0000", x"FFFF"
   ),
   ( 
    x"0000", x"0000", x"FFFF", x"FFFF", x"FFFF", x"FFFF", 
    x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"0000", 
    x"0003", x"0007", x"000B", x"0010", x"0014", x"0016", 
    x"0014", x"000E", x"0003", x"FFF2", x"FFDB", x"FFC1", 
    x"FFA7", x"FF91", x"FF84", x"FF87", x"FF9D", x"FFCB", 
    x"000F", x"0069", x"00D0", x"013B", x"0199", x"01D9", 
    x"01EB", x"01BC", x"013F", x"006C", x"FF44", x"FDCC", 
    x"FC14", x"FA36", x"F850", x"F682", x"F4EF", x"F3B6", 
    x"F2EF", x"72AA", x"F2EF", x"F3B6", x"F4EF", x"F682", 
    x"F850", x"FA36", x"FC14", x"FDCC", x"FF44", x"006C", 
    x"013F", x"01BC", x"01EB", x"01D9", x"0199", x"013B", 
    x"00D0", x"0069", x"000F", x"FFCB", x"FF9D", x"FF87", 
    x"FF84", x"FF91", x"FFA7", x"FFC1", x"FFDB", x"FFF2", 
    x"0003", x"000E", x"0014", x"0016", x"0014", x"0010", 
    x"000B", x"0007", x"0003", x"0000", x"FFFF", x"FFFF", 
    x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", 
    x"FFFF", x"0000", x"0000"
   )
   );
begin 

    
    
    shiftSamplesAndMul : process(clock,reset)
        
        variable accumulator1 : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
        variable accumulator2 : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin        
        if (reset = '1') then
            samples <= (others =>(others => '0'));
            cnt <= (others => '0');
            cnt2 <= (others => '0');
            calculate <= (others => '0');
            calculatedelayed <= (others => '0');
            oldLRCK <= '0';
            selector <= (others => '0');
            wAddrCnt <= to_unsigned(initialWAddress,wAddrCnt'length);
            firstWrite <= '0';
            firstRead <= (others => '0');
            RAMfull <= '0';
            RAMfulldelayed <= '0';
            cntNooffset <= (others => '0');
        elsif rising_edge(clock) then  
            
            we <= '0';
            if en = '1' then
                
                firstWrite <= '1';
                initialRAddress <= ((wAddrCnt+(2*n)- initialWAddress) mod (2*(FILTER_TAP_NB) ));
                wAddrCnt <= wAddrCnt + n;
                we <= '1';
                din <= unsigned(audio_In(audio_In'length-1 downto (audio_In'length-(audio_In'length/2))));
                wraddr <= wAddrCnt;
                
            end if;
           
            if firstWrite = '1' then 
                calculate <= to_unsigned(1,calculate'length);
                cntNooffset   <= (others => '0');   
                firstWrite <= '0';
                wAddrCnt <= wAddrCnt + n;
                
                rAddrCnt_Plus <= initialRAddress;
                rdaddr <= initialRAddress; 
                if wAddrCnt >= RAMLength then
                    RAMfull <= '1';
                
                    wAddrCnt <= to_unsigned(initialWAddress,wAddrCnt'length);
                end if;
                RAMfulldelayed <= RAMfull;
                we <= '1';
                din <= unsigned(audio_In((audio_In'length-(audio_In'length/2)-1) downto 0));
                wraddr <= wAddrCnt;
            end if ; 
            
            calculatedelayed <= calculate;
            re <= '0';
           
         
            
            if calculatedelayed > 0  and RAMfull = '1' then 
                
                re <= '1';
                if cntNooffset < 5 then 
                    sample1 <= (others => '0');
                    cnt <= (others => '0');
                end if ;
                if cntNooffset >= RAMLength + 2 then 
                    calculate <= calculate-1;   
                    cntNooffset   <= (others => '0');   
                    lowPass <= resize(shift_right(accumulator1,ACCUMULATOR_Bit_NB-Lowpass'length-8),Lowpass'length);
                    Highpass <= resize(shift_right(accumulator2,ACCUMULATOR_Bit_NB-Lowpass'length-8),Lowpass'length);
                    cnt <= (others => '0');  
                    accumulator1 := (others => '0'); 
                    accumulator2 := (others => '0');  
                else
                    cntNooffset <= cntNooffset + 1; 
                end if;
                rdaddr <= rAddrCnt_Plus; 
                if (rAddrCnt_Plus mod 2) = 0 then 
                    rAddrCnt_Plus <= rAddrCnt_Plus + 1;
                    firstRead <= firstRead +1;
                    temp1(temp1'length-1 downto (temp1'length-(temp1'length/2))) <= signed(dout1);
                    sample1 <= temp1; 
                end if;
                if (rAddrCnt_Plus mod 2 = 1)  then 
                    rAddrCnt_Plus <= rAddrCnt_Plus + 1;
                    firstRead <= (others => '0');
                    temp1((temp1'length-(temp1'length/2)-1) downto 0)  <= signed(dout1);
                   
                end if;
              
              
                
                if rAddrCnt_Plus >= RAMLength then     
                    rAddrCnt_Plus  <= to_unsigned(initialWAddress,wAddrCnt'length);
                end if;
                
                if cntNooffset >= 5  and cntNooffset mod 2  = 1 then 
                
                    cnt <= cnt+1;
                    accumulator1 := accumulator1 + sample1 * coeff(0,to_integer(cnt));
                    accumulator2 := accumulator2 + sample1 * coeff(1,to_integer(cnt));
                
                end if;
                
                
                
                -- if cnt = HALF_FILTER_TAP_NB-1  then 
                    
                    -- if selector = 0 then 
                        -- selector <= selector+1;
                        -- accumulator1 <= accumulator1 + resize((samples(to_integer(cnt)) * coeff(0,to_integer(cnt))),mul_v1'length);       
                    -- else 
                        -- selector <= (others => '0');
                        -- accumulator2 <= accumulator2 + resize((samples(to_integer(cnt)) * coeff(1,to_integer(cnt))),mul_v2'length);                       
                        -- cnt <= cnt + 1;      
                    -- end if;
                    
                   
                    
                
                                   
                -- elsif cnt <  HALF_FILTER_TAP_NB-1  then
                    
                    -- if selector = 0 then 
                        -- sum_v <= resize(samples(to_integer(cnt)),audio_In'length+1)
                        -- + samples(FILTER_TAP_NB-1-to_integer(cnt));
                        -- selector <= selector+1; 
                    -- end if;
                    
                    -- if selector = 1 then 
                        -- accumulator1 <= accumulator1 + sum_v*coeff(0,to_integer(cnt));
                        -- selector <= selector+1;
                    -- end if;
                    
                    -- if selector = 2 then 
                        -- accumulator2 <= accumulator2 + sum_v*coeff(1,to_integer(cnt));
                        -- cnt <= cnt + 1;
                        -- selector <= (others => '0');
                    -- end if;
                   
                    
                -- elsif cnt > HALF_FILTER_TAP_NB-1  then 
                   
                     -- if selector = 0 then 
                        -- lowPass <= resize(shift_right(accumulator1,ACCUMULATOR_Bit_NB-Lowpass'length-9),Lowpass'length);
                        -- selector <= selector+1;
                    -- else 
                        -- selector <= (others => '0');
                        -- Highpass <= resize(shift_right(accumulator2,ACCUMULATOR_Bit_NB-Lowpass'length-9),Lowpass'length);
                        -- calculate <= calculate-1; 
                        -- cnt <= (others => '0');  
                        -- accumulator1 <= (others => '0'); 
                        -- accumulator2 <= (others => '0');  
                        -- sum_v <= (others => '0');  
                        -- mul_v1 <= (others => '0');  
                        -- mul_v2 <= (others => '0');                          
                    -- end if;
                -- end if;  
               
            
                   
            end if;
           
            
        end if ;
    end process shiftSamplesAndMul;
    
     DataReady <= '1' when calculate = 0 else '0';
     -- DebugData(1) <= accumulator1(accumulator1'high); 
     -- DebugData(0) <= accumulator1(accumulator1'high-1); 
     

    
     
END ARCHITECTURE FirstArchi;

