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
    x"FFC3", x"FFC1", x"FFC6", x"FFD2", x"FFE8", x"0007", 
    x"0033", x"006B", x"00B0", x"0102", x"0160", x"01C9", 
    x"023B", x"02B5", x"0333", x"03B3", x"0432", x"04AC", 
    x"051E", x"0585", x"05DE", x"0626", x"065B", x"067C", 
    x"0687");
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

