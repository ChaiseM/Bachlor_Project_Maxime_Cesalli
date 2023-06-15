--
-- VHDL Architecture Splitter.HighPass.ParalelSym
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 11:19:05 12.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE ParalelSym OF HighPass IS

    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT ;    
    constant ShiftNB : positive := ACCUMULATOR_Bit_NB-HighpassOut'length-7;    
    -- +1 because it is symetrical we add two samples together
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioIn'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    signal fromage : std_ulogic;
    -- 
    signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    
    type coefficients is array (0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
        signal coeff: coefficients :=( 
    x"FFEE", x"FFDC", x"FFC7", x"FFB2", x"FFA4", x"FFA1", 
    x"FFAF", x"FFD3", x"000D", x"005E", x"00BE", x"0124", 
    x"0180", x"01C2", x"01D7", x"01AE", x"0137", x"006A", 
    x"FF47", x"FDD2", x"FC1D", x"FA40", x"F858", x"F689", 
    x"F4F4", x"F3B9", x"F2F1", x"72A0");
begin 
 
    shiftSamples : process(clock,reset)
    begin
        if (reset = '1') then
            samples <= (others =>(others => '0'));
        elsif rising_edge(clock) then  
        
            if en = '1' then
                samples(0) <= audioIn ;
                shift : for ii in 0 to FILTER_TAP_NB-2 loop
                    samples(ii+1) <= samples(ii) ;  
                end loop shift;
                
            end if ; 
        
        end if;
       
    end process shiftSamples;
 
    multiplyAdd : process(samples)
        variable adder : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin 
        adder := (others => '0');
        
        multAdd : for ii in 0 to HALF_FILTER_TAP_NB-1 loop
           
            if ii = HALF_FILTER_TAP_NB-1 and (FILTER_TAP_NB mod 2)= 1  then 
                adder := adder + samples(ii) * coeff(ii);   
            else
                adder := adder +(resize(samples(ii),audioIn'length+1)+samples(FILTER_TAP_NB-1-ii))*coeff(ii);
            end if;
            
        end loop multAdd;
        accumulator <=  adder;
        
        --HighpassOut <= adder;
       --HighpassOut <= adder(ACCUMULATOR_Bit_NB-3 downto ACCUMULATOR_Bit_NB-HighpassOut'length-2);
       HighpassOut <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-HighpassOut'length-7),HighpassOut'length);
       -- HighpassOut <= adder(ACCUMULATOR_Bit_NB-19 downto ACCUMULATOR_Bit_NB-HighpassOut'length-18);
    end process multiplyAdd;
END ARCHITECTURE ParalelSym;

