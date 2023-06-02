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
    -- +1 because it is symetrical we add two samples together
    constant ADDER_BIT_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT + 1; 
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioIn'range);  -- vector of 50 signed elements
    signal      samples : t_samples ; 
    signal fromage : std_ulogic;
    -- 
    type coefficients is array (0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=( 
    x"0030", x"003B", x"003F", x"0037", x"0020", x"FFF7", 
    x"FFBA", x"FF6D", x"FF18", x"FEC5", x"FE84", x"FE66", 
    x"FE7E", x"FEDD", x"FF8F", x"0099", x"01FA", x"03A6", 
    x"0585", x"0778", x"095B", x"0B08", x"0C58", x"0D2F", 
    x"0D79");
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
        variable adder : signed (ADDER_BIT_NB-1 DOWNTO 0);
    begin 
        adder := (others => '0');
        
        multAdd : for ii in 0 to HALF_FILTER_TAP_NB-1 loop
           
            if ii = HALF_FILTER_TAP_NB-1 and (FILTER_TAP_NB mod 2)= 1  then 
                adder := adder + samples(ii) * coeff(ii);   
            else
                adder := adder +(resize(samples(ii),audioIn'length+1)+samples(FILTER_TAP_NB-1-ii))*coeff(ii);
            end if;
            
        end loop multAdd;
        
        
        audioOut <= resize(shift_right(adder, COEFF_BIT_NB+FINAL_SHIFT-7), audioOut'length);
       -- audioOut <= resize(shift_right(adder, COEFF_BIT_NB+7), audioOut'length);
        
    end process multiplyAdd;
END ARCHITECTURE paralelSYM;

