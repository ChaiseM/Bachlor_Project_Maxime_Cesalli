--
-- VHDL Architecture Splitter.HighPass.serie
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 11:41:09 21.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
    ARCHITECTURE serie OF HighPass IS
    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB); 
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioIn'length + FINAL_SHIFT;
    --constant ShiftNB : positive := ACCUMULATOR_Bit_NB-HighpassOut'length;
    type        t_samples is array (0 to FILTER_TAP_NB-1) of signed(audioIn'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    signal calculate  : std_uLogic;
    signal test2 : signed(ACCUMULATOR_Bit_NB-1 downto 0);
    signal test1 : signed( COEFF_BIT_NB-1 downto 0);
    signal cnt   : unsigned(FINAL_SHIFT-1 DOWNTO 0);
    -- 
      type coefficients is array (0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
        signal coeff: coefficients :=( 
        x"FFFF", x"FFFF", x"FFFF", x"FFFD", x"FFFC", x"FFFB", 
        x"FFFA", x"FFFA", x"FFFC", x"FFFF", x"0004", x"000B", 
        x"0014", x"001C", x"0024", x"0029", x"002A", x"0024", 
        x"0017", x"0003", x"FFE8", x"FFC6", x"FFA3", x"FF82", 
        x"FF68", x"FF5B", x"FF60", x"FF7C", x"FFB0", x"FFFC", 
        x"005B", x"00C9", x"0138", x"019E", x"01E9", x"020B", 
        x"01F6", x"019C", x"00F7", x"0004", x"FEC9", x"FD4E", 
        x"FBA5", x"F9E6", x"F829", x"F68C", x"F528", x"F417", 
        x"F36A", x"732F");
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
                if cnt >= HALF_FILTER_TAP_NB-1 then 
                    
                    if (FILTER_TAP_NB mod 2)= 1 then 
                        adder := adder + samples(to_integer(cnt)) * coeff(to_integer(cnt)   );  
                    end if; 
                    HighpassOut <=  resize(shift_right(adder,ACCUMULATOR_Bit_NB-HighpassOut'length-8),HighpassOut'length);
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
        
        DataReady <= calculate;
    end process shiftSamplesAndMul;
    
END ARCHITECTURE serie;

