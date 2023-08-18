--
-- VHDL Architecture Splitter.Lowpass1.UltraSimple
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 10:04:05 09.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE UltraSimple OF Lowpass1 IS


    type        t_samples is array (0 to 5) of signed (audioIn'range);  -- vector of 50 signed elements
    signal      samples : t_samples ;

    type coefficients is array (0 to 5) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=( 
    x"2BA7003C", x"085096BE", x"0891D01F", 
    x"0891D01F", x"085096BE", x"2BA7003C");




BEGIN

    shiftSamples : process(clock,reset)
    begin
        if (reset = '1') then
            samples <= (others =>(others => '0'));
        elsif rising_edge(clock) then  
        
            if en = '1' then 
                samples(0) <= audioIn;
                samples(1) <= samples(0);
                samples(2) <= samples(1);
                samples(3) <= samples(2);
                samples(4) <= samples(3);
                samples(5) <= samples(4);
            end if ; 
        end if;
    end process shiftSamples;
    
    addAndMultipy : process(samples)
         variable adder : signed (audioOut'length+(COEFF_BIT_NB-1)+3 DOWNTO 0);
    begin 
        adder := (others => '0');
        adder := adder + (samples(0)*coeff(0));
        adder := adder + (samples(1)*coeff(1));
        adder := adder + (samples(2)*coeff(2));
        adder := adder + (samples(3)*coeff(3));
        adder := adder + (samples(4)*coeff(4));
        adder := adder + (samples(5)*coeff(5));
        audioOut <= resize(shift_right(adder,COEFF_BIT_NB-1),audioOut'length);
    end process addAndMultipy;
    
END ARCHITECTURE UltraSimple;

