--
-- VHDL Architecture Splitter.Lowpass1.Serial
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 13:28:40 01.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE Serial OF Lowpass1 IS
    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2;
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB); 
    constant ADDER_BIT_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT;
    --constant ShiftNB : positive := ADDER_BIT_NB-audioOut'length;
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed(audioIn'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    signal debug : signed (ADDER_BIT_NB-1 DOWNTO 0);
    signal test2 : signed (ADDER_BIT_NB-1 DOWNTO 0);
    signal test1 : signed (ADDER_BIT_NB-1 DOWNTO 0);
    signal cnt   : unsigned(FINAL_SHIFT-1 DOWNTO 0);
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
 
    multiplyAdd : process(clock,reset)
        variable adder : signed (ADDER_BIT_NB-1 DOWNTO 0);
    begin        
         if (reset = '1') then
            samples <= (others =>(others => '0'));
            cnt <= (others => '0');
        elsif rising_edge(clock) then  
           
            if cnt = HALF_FILTER_TAP_NB-1  then 
                
                if (FILTER_TAP_NB mod 2)= 1 then 
                    adder := adder + samples(to_integer(cnt)) * coeff(to_integer(cnt));  
                end if; 
                audioOut <= unsigned(adder);    
                cnt <= (others => '0');    
            else
                adder := adder +(resize(samples(to_integer(cnt)),audioIn'length+1)+
                samples(FILTER_TAP_NB-1-to_integer(cnt)))*coeff(to_integer(cnt));
                cnt <= cnt + 1;
            end if;
           debug <= adder;
            
        end if ;
    end process multiplyAdd;
    
     
    
END ARCHITECTURE Serial;
