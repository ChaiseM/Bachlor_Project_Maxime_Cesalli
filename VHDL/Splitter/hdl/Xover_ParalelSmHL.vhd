ARCHITECTURE ParalelSmHL OF Xover IS
    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioMono'length + FINAL_SHIFT ;    
  
    
    -- +1 because it is symetrical we add two samples together
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioMono'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    
    -- 
    --signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    signal sys_LRCK : integer := 0 ;
    type coefficients is array (0 to 1,0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=(
    ( 
    x"0012", x"0024", x"0039", x"004E", x"005C", x"005F", 
    x"0051", x"002D", x"FFF3", x"FFA2", x"FF42", x"FEDC", 
    x"FE80", x"FE3E", x"FE28", x"FE52", x"FEC9", x"FF96", 
    x"00B9", x"022E", x"03E3", x"05C1", x"07A9", x"0978", 
    x"0B0D", x"0C48", x"0D10", x"0D55"),
    (x"FFEE", x"FFDC", x"FFC7", x"FFB2", x"FFA4", x"FFA1", 
    x"FFAF", x"FFD3", x"000D", x"005E", x"00BE", x"0124", 
    x"0180", x"01C2", x"01D7", x"01AE", x"0137", x"006A", 
    x"FF47", x"FDD2", x"FC1D", x"FA40", x"F858", x"F689", 
    x"F4F4", x"F3B9", x"F2F1", x"72A0"));
begin 
 
    shiftSamples : process(clock,reset)
    begin
        if (reset = '1') then
            samples <= (others =>(others => '0'));
        elsif rising_edge(clock) then  
        
             if en = '1' then
                -- shifting the registers 
                -- the first info goes to samples 0
                samples(0) <= audioMono ;
                -- loop to shift the samples 
                shift : for ii in 0 to FILTER_TAP_NB-2 loop
                    samples(ii+1) <= samples(ii) ;
                end loop shift;
            end if;
        
        end if;
       
    end process shiftSamples;
    
    sys_LRCK <= 1 when (lrck = '1') else 0;
    
    multiplyAdd : process(lrck)
        variable adder : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin 
        adder := (others => '0');
     
        multAdd : for ii in 0 to HALF_FILTER_TAP_NB-1 loop
           
            if ii = HALF_FILTER_TAP_NB-1 and (FILTER_TAP_NB mod 2)= 1  then 
                adder := adder + samples(ii) * coeff(sys_LRCK,ii);   
            else
                adder := adder +(resize(samples(ii),audioMono'length+1)+samples(FILTER_TAP_NB-1-ii))*coeff(sys_LRCK,ii);
            end if;
            
        end loop multAdd;
        --accumulator <=  adder;
        
        --Lowpass <= adder;
       --Lowpass <= adder(ACCUMULATOR_Bit_NB-3 downto ACCUMULATOR_Bit_NB-Lowpass'length-2);
        if lrck = '0' then 
            lowPass <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-Lowpass'length-7),Lowpass'length);
            --savedLowpass <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-Lowpass'length-7),Lowpass'length);
            --Highpass <= savedHighpass;
        else 
            Highpass <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-Lowpass'length-7),Lowpass'length);
            --savedHighpass <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-Lowpass'length-7),Lowpass'length);
            --lowPass <= savedLowpass;
        end if ;
     
       -- Lowpass <= adder(ACCUMULATOR_Bit_NB-19 downto ACCUMULATOR_Bit_NB-Lowpass'length-18);
    end process multiplyAdd;
    
END ARCHITECTURE ParalelSmHL;

