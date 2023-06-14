--
-- VHDL Architecture Splitter.Xover.ParalelSmHL
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 14:41:53 12.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE ParalelSmHL OF Xover IS
    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioMono'length + FINAL_SHIFT ;    
    --constant ShiftNB : positive := ACCUMULATOR_Bit_NB-Lowpass'length-7; 
    --signal savedHighpass : signed (audioMono'range);
    --signal savedLowpass : signed (audioMono'range);
    
    -- +1 because it is symetrical we add two samples together
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioMono'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    
    -- 
    --signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    signal sys_LRCK : integer := 0 ;
    type coefficients is array (0 to 1,0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=(
    ( x"FFC3", x"FFC1", x"FFC6", x"FFD2", x"FFE8", x"0007", 
    x"0033", x"006B", x"00B0", x"0102", x"0160", x"01C9", 
    x"023B", x"02B5", x"0333", x"03B3", x"0432", x"04AC", 
    x"051E", x"0585", x"05DE", x"0626", x"065B", x"067C", 
    x"0687"),
    ( x"003E", x"0040", x"003B", x"002F", x"0019", x"FFF9", 
    x"FFCC", x"FF93", x"FF4D", x"FEF9", x"FE99", x"FE2E", 
    x"FDBA", x"FD3E", x"FCBD", x"FC3B", x"FBB9", x"FB3D", 
    x"FAC8", x"FA5F", x"FA05", x"F9BB", x"F985", x"F964", 
    x"791B"));
begin 
 
    shiftSamples : process(clock,reset)
    begin
        if (reset = '1') then
            samples <= (others =>(others => '0'));
        elsif rising_edge(clock) then  
        
            if en = '1' then
                samples(0) <= audioMono ;
                shift : for ii in 0 to FILTER_TAP_NB-2 loop
                    samples(ii+1) <= samples(ii) ;  
                end loop shift;
                
            end if ; 
        
        end if;
       
    end process shiftSamples;
    
    sys_LRCK <= 1 when (lrck = '1') else 0;
    
    multiplyAdd : process(samples)
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

