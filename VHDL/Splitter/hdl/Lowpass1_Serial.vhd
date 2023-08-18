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
    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB); 
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT;
    --constant ShiftNB : positive := ACCUMULATOR_Bit_NB-LowPassOut'length;
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed(audioIn'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    signal calculate  : std_uLogic;
    signal test2 : signed(ACCUMULATOR_Bit_NB-1 downto 0);
    signal test1 : signed( COEFF_BIT_NB-1 downto 0);
    signal cnt   : unsigned(FINAL_SHIFT-1 DOWNTO 0);
    -- 
      type coefficients is array (0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=( 
    x"0012", x"0024", x"0039", x"004E", x"005C", x"005F", 
    x"0051", x"002D", x"FFF3", x"FFA2", x"FF42", x"FEDC", 
    x"FE80", x"FE3E", x"FE28", x"FE52", x"FEC9", x"FF96", 
    x"00B9", x"022E", x"03E3", x"05C1", x"07A9", x"0978", 
    x"0B0D", x"0C48", x"0D10", x"0D55");
begin 
 
    shiftSamplesAndMul : process(clock,reset)
        variable adder : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin        
        if (reset = '1') then
            samples <= (others =>(others => '0'));
            cnt <= (others => '0');
            calculate <= '0';
        elsif rising_edge(clock) then  
        
            if en = '1' then
                samples(0) <= audioIn ;
                calculate <= '1';
                shift : for ii in 0 to FILTER_TAP_NB-2 loop
                    samples(ii+1) <= samples(ii) ;
                end loop shift;
            end if ; 
        
        
            if calculate = '1' then 
                if cnt = HALF_FILTER_TAP_NB-1  then 
                    
                    if (FILTER_TAP_NB mod 2)= 1 then 
                        adder := adder + samples(to_integer(cnt)) * coeff(to_integer(cnt));  
                    end if; 
                    LowPassOut <=  resize(shift_right(adder,ACCUMULATOR_Bit_NB-LowPassOut'length-7),LowPassOut'length);
                    cnt <= (others => '0');  
                    adder := (others => '0');
                    test2 <= (others => '0');
                    calculate <= '0';                    
                else
                    adder := adder +((resize(samples(to_integer(cnt)),audioIn'length+1)+samples(FILTER_TAP_NB-1-to_integer(cnt)))*coeff(to_integer(cnt)));
                    
                    cnt <= cnt + 1;
                end if;  
                test1   <= coeff(to_integer(cnt));
                test2 <= ((resize(samples(to_integer(cnt)),audioIn'length+1)+samples(FILTER_TAP_NB-1-to_integer(cnt)))*coeff(to_integer(cnt)));
            end if;
        end if ;
    end process shiftSamplesAndMul;
    
     
    
END ARCHITECTURE Serial;

