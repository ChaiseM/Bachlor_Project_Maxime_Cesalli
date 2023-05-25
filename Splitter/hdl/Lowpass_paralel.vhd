--
-- VHDL Architecture Splitter.Lowpass.paralel
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 16:58:21 25.05.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE paralel OF Lowpass IS
 constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2;
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);  
    constant ADDER_BIT_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT;
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed (audioIn'range);  -- vector of 50 signed elements
    signal      samples : t_samples ; 
    -- 
    type coefficients is array (0 to FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=( 
    x"FFFE", x"000A", x"001E", x"0036", x"0050", x"0068", 
    x"0076", x"0076", x"0061", x"0035", x"FFF1", x"FF96", 
    x"FF2D", x"FEC0", x"FE60", x"FE1F", x"FE0E", x"FE3E", 
    x"FEBD", x"FF93", x"00BE", x"0238", x"03F0", x"05CD", 
    x"07B1", x"097C", x"0B0B", x"0C41", x"0D06", x"0D49", 
    x"0D06", x"0C41", x"0B0B", x"097C", x"07B1", x"05CD", 
    x"03F0", x"0238", x"00BE", x"FF93", x"FEBD", x"FE3E", 
    x"FE0E", x"FE1F", x"FE60", x"FEC0", x"FF2D", x"FF96", 
    x"FFF1", x"0035", x"0061", x"0076", x"0076", x"0068", 
    x"0050", x"0036", x"001E", x"000A", x"FFFE");
 
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
        
        multAdd : for ii in 0 to FILTER_TAP_NB-1 loop
        
            adder := adder + samples(ii)*coeff(ii);
            
        end loop multAdd;
        audioOut <= resize(shift_right(adder, COEFF_BIT_NB+FINAL_SHIFT), audioOut'length);

    end process multiplyAdd;
END ARCHITECTURE paralel;

