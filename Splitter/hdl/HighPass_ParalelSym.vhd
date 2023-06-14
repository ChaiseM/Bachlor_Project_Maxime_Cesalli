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
    x"003E", x"0040", x"003B", x"002F", x"0019", x"FFF9", 
    x"FFCC", x"FF93", x"FF4D", x"FEF9", x"FE99", x"FE2E", 
    x"FDBA", x"FD3E", x"FCBD", x"FC3B", x"FBB9", x"FB3D", 
    x"FAC8", x"FA5F", x"FA05", x"F9BB", x"F985", x"F964", 
    x"791B");
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

