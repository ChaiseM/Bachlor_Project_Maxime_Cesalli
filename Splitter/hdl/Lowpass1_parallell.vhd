--
-- VHDL Architecture Splitter.Lowpass1.parallell
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 17:09:34 25.05.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE parallell OF Lowpass1 IS
 constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2;
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB); 
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT+6;
    --constant ShiftNB : positive := ACCUMULATOR_Bit_NB-audioOut'length+15;
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioIn'range);  -- vector of 50 signed elements
    signal      samples : t_samples ; 
    signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    signal test2 : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    signal test1 : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    -- 
    type coefficients is array (0 to FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=( 
    x"0183", x"00D7", x"00A5", x"0013", x"FF2D", x"FE1B", 
    x"FD28", x"FCAE", x"FD07", x"FE75", x"010A", x"049E", 
    x"08CD", x"0D08", x"10AB", x"1320", x"13FE", x"1320", 
    x"10AB", x"0D08", x"08CD", x"049E", x"010A", x"FE75", 
    x"FD07", x"FCAE", x"FD28", x"FE1B", x"FF2D", x"0013", 
    x"00A5", x"00D7", x"0183");
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
        
        multAdd : for ii in 0 to FILTER_TAP_NB-1 loop
        
            adder := adder + samples(ii)*coeff(ii);
            
        end loop multAdd;
      
        accumulator <= adder;

        audioOut <= adder(ACCUMULATOR_Bit_NB-12 downto ACCUMULATOR_Bit_NB-audioOut'length-11);
        --audioOut <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-audioOut'length-13),audioOut'length);
        --audioOut <= unsigned(adder);
       --audioOut <= adder;
    end process multiplyAdd;
    
     
    
END ARCHITECTURE parallell;