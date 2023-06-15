--
-- VHDL Architecture Splitter.Lowpass1.paralelSYM
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 16:09:52 30.05.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE paralelSYM OF Lowpass1 IS
    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT ;    
    constant ShiftNB : positive := ACCUMULATOR_Bit_NB-LowPassOut'length-7;    
    -- +1 because it is symetrical we add two samples together
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioIn'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    signal fromage : std_ulogic;
    -- 
    signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    
    type coefficients is array (0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=( 
    x"0012", x"0024", x"0039", x"004E", x"005C", x"005F", 
    x"0051", x"002D", x"FFF3", x"FFA2", x"FF42", x"FEDC", 
    x"FE80", x"FE3E", x"FE28", x"FE52", x"FEC9", x"FF96", 
    x"00B9", x"022E", x"03E3", x"05C1", x"07A9", x"0978", 
    x"0B0D", x"0C48", x"0D10", x"0D55");
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
        
        -- for Hardware 
        LowPassOut <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-LowPassOut'length-7),LowPassOut'length);
        -- for simulation
        --LowPassOut <= resize(shift_right(adder,ACCUMULATOR_Bit_NB-LowPassOut'length-6),LowPassOut'length);
    end process multiplyAdd;
END ARCHITECTURE paralelSYM;

