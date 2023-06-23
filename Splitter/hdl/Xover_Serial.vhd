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
    signal cnt2 :  unsigned (2 downto 0);
    -- 
    --signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    signal sys_LRCK : integer := 0 ;
    -- lowpass firtst then highpass coeff
    type coefficients is array (0 to 1,0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=(
    ( 
    x"FFFF", x"FFFF", x"FFFF", x"0000", x"0002", x"0004", 
    x"0006", x"0009", x"000A", x"000B", x"000A", x"0006", 
    x"FFFF", x"FFF6", x"FFEA", x"FFDD", x"FFD1", x"FFC9", 
    x"FFC6", x"FFCC", x"FFDC", x"FFF7", x"001B", x"0047", 
    x"0074", x"009E", x"00BC", x"00C7", x"00B7", x"0089", 
    x"003B", x"FFD1", x"FF50", x"FEC7", x"FE48", x"FDE5", 
    x"FDB6", x"FDCE", x"FE3C", x"FF0D", x"003F", x"01CD", 
    x"03A5", x"05AB", x"07BE", x"09B9", x"0B74", x"0CCD", 
    x"0DA9", x"0DF4"),
   ( 
    x"FFFF", x"FFFF", x"FFFF", x"FFFD", x"FFFC", x"FFFB", 
    x"FFFA", x"FFFA", x"FFFC", x"FFFF", x"0004", x"000B", 
    x"0014", x"001C", x"0024", x"0029", x"002A", x"0024", 
    x"0017", x"0003", x"FFE8", x"FFC6", x"FFA3", x"FF82", 
    x"FF68", x"FF5B", x"FF60", x"FF7C", x"FFB0", x"FFFC", 
    x"005B", x"00C9", x"0138", x"019E", x"01E9", x"020B", 
    x"01F6", x"019C", x"00F7", x"0004", x"FEC9", x"FD4E", 
    x"FBA5", x"F9E6", x"F829", x"F68C", x"F528", x"F417", 
    x"F36A", x"732F")
   );
begin 

    sys_LRCK <= 1 when (lrck = '1') else 0;
    
    shiftSamplesAndMul : process(clock,reset)
        variable adder : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin        
        if (reset = '1') then
            samples <= (others =>(others => '0'));
            cnt <= (others => '0');
            cnt2 <= (others => '0');
            calculate <= '0';
            oldLRCK <= '0';
        elsif rising_edge(clock) then  
            
            if en = '1' then
                cnt2 <= cnt2 + 1;
                calculate <= '1';
            end if;
            if cnt2 = 2 then 
                cnt2 <= (others => '0');
                samples(0) <= audioMono ;
                shift : for ii in 0 to FILTER_TAP_NB-2 loop
                    samples(ii+1) <= samples(ii) ;
                end loop shift;
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
            
            DataReady <= calculate;
            
        end if ;
    end process shiftSamplesAndMul;
    
    
END ARCHITECTURE Serial;

