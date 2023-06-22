--
-- VHDL Architecture Splitter.Xover.Serial
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 12:57:16 21.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE Serial OF Xover IS
constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioMono'length + FINAL_SHIFT ;    
    --constant ShiftNB : positive := ACCUMULATOR_Bit_NB-Lowpass'length-7; 
    --signal savedHighpass : signed (audioMono'range);
    --signal savedLowpass : signed (audioMono'range);
    
    -- +1 because it is symetrical we add two samples together
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioMono'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    signal oldLRCK : std_ulogic;
    signal calculate  : std_uLogic;
    signal cnt   : unsigned(FINAL_SHIFT-1 DOWNTO 0);
    -- 
    --signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    signal sys_LRCK : integer := 0 ;
    -- lowpass firtst then highpass coeff
    type coefficients is array (0 to 1,0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=(
    ( 
    x"0000", x"0000", x"0000", x"0000", x"0001", x"0001", x"0001", x"0000", x"0000", x"FFFF", 
    x"FFFF", x"FFFF", x"FFFE", x"FFFE", x"FFFD", x"FFFD", x"FFFE", x"FFFF", x"FFFF", x"0001", 
    x"0002", x"0004", x"0006", x"0007", x"0007", x"0007", x"0005", x"0003", x"0000", x"FFFD", 
    x"FFF9", x"FFF6", x"FFF3", x"FFF2", x"FFF2", x"FFF4", x"FFF7", x"FFFD", x"0002", x"0009", 
    x"0010", x"0015", x"0019", x"001A", x"0018", x"0014", x"000C", x"0002", x"FFF7", x"FFEC", 
    x"FFE1", x"FFD9", x"FFD5", x"FFD5", x"FFDA", x"FFE4", x"FFF3", x"0003", x"0016", x"0028", 
    x"0038", x"0042", x"0046", x"0042", x"0036", x"0023", x"000B", x"FFEF", x"FFD2", x"FFB7", 
    x"FFA3", x"FF97", x"FF96", x"FFA0", x"FFB7", x"FFD8", x"0000", x"002C", x"0057", x"007C", 
    x"0096", x"00A2", x"009C", x"0084", x"005C", x"0025", x"FFE6", x"FFA4", x"FF65", x"FF33", 
    x"FF13", x"FF0B", x"FF1E", x"FF4C", x"FF93", x"FFED", x"0051", x"00B7", x"0113", x"0159", 
    x"0180", x"017F", x"0153", x"00FB", x"007B", x"FFDF", x"FF31", x"FE84", x"FDEA", x"FD76", 
    x"FD3C", x"FD4A", x"FDAC", x"FE68", x"FF7B", x"00DE", x"0283", x"0454", x"0639", x"0816", 
    x"09CE", x"0B45", x"0C63", x"0D17", x"0D55"),
   ( 
    x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"0000", 
    x"0000", x"0001", x"0002", x"0002", x"0003", x"0003", x"0002", x"0001", x"0000", x"FFFF", 
    x"FFFE", x"FFFC", x"FFFA", x"FFF9", x"FFF9", x"FFF9", x"FFFB", x"FFFD", x"0000", x"0003", 
    x"0007", x"000A", x"000D", x"000E", x"000E", x"000C", x"0009", x"0003", x"FFFE", x"FFF7", 
    x"FFF0", x"FFEB", x"FFE7", x"FFE6", x"FFE8", x"FFEC", x"FFF4", x"FFFE", x"0009", x"0014", 
    x"001F", x"0027", x"002B", x"002B", x"0026", x"001C", x"000D", x"FFFD", x"FFEA", x"FFD8", 
    x"FFC8", x"FFBE", x"FFBA", x"FFBE", x"FFCA", x"FFDD", x"FFF5", x"0011", x"002E", x"0049", 
    x"005D", x"0069", x"006A", x"0060", x"0049", x"0028", x"0000", x"FFD4", x"FFA9", x"FF84", 
    x"FF6A", x"FF5E", x"FF64", x"FF7C", x"FFA4", x"FFDB", x"001A", x"005C", x"009B", x"00CD", 
    x"00ED", x"00F5", x"00E2", x"00B4", x"006D", x"0013", x"FFAF", x"FF49", x"FEED", x"FEA7", 
    x"FE80", x"FE81", x"FEAD", x"FF05", x"FF84", x"0021", x"00CF", x"017C", x"0216", x"028A", 
    x"02C4", x"02B6", x"0254", x"0198", x"0085", x"FF22", x"FD7D", x"FBAC", x"F9C7", x"F7EA", 
    x"F632", x"F4BB", x"F39C", x"F2E8", x"72AA")
   );
begin 

    sys_LRCK <= 1 when (lrck = '1') else 0;
    
    shiftSamplesAndMul : process(clock,reset)
        variable adder : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin        
        if (reset = '1') then
            samples <= (others =>(others => '0'));
            cnt <= (others => '0');
            calculate <= '0';
            oldLRCK <= '0';
        elsif rising_edge(clock) then  
        
            if en = '1' then
                samples(0) <= audioMono ;
                
                shift : for ii in 0 to FILTER_TAP_NB-2 loop
                    samples(ii+1) <= samples(ii) ;
                end loop shift;
            end if ; 
            
            if  lrck = '0' and oldLRCK = '1' then 
                oldLRCK <= '0';
                calculate <= '1';
            elsif  lrck = '1' and oldLRCK = '0' then 
                oldLRCK <= '1';
                calculate <= '1';
            end if ;
        
            if calculate = '1' then 
                if cnt = HALF_FILTER_TAP_NB-1  then 
                    
                    if (FILTER_TAP_NB mod 2)= 1 then 
                        adder := adder + samples(to_integer(cnt)) * coeff(sys_LRCK,to_integer(cnt));  
                    end if; 
                    if lrck = '0' then 
                        lowPass <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-Lowpass'length-7),Lowpass'length);
                    else 
                        Highpass <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-Lowpass'length-7),Lowpass'length);
                    end if ;
                    cnt <= (others => '0');  
                    adder := (others => '0');
                    calculate <= '0';                    
                else
                    adder := adder +((resize(samples(to_integer(cnt)),audioMono'length+1)+
                    samples(FILTER_TAP_NB-1-to_integer(cnt)))*coeff(sys_LRCK,to_integer(cnt)));
                    cnt <= cnt + 1;
                end if;  
               
            end if;
        end if ;
    end process shiftSamplesAndMul;
END ARCHITECTURE Serial;

