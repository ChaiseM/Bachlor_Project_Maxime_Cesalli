--
-- VHDL Architecture Splitter.Lowpass1.internetExemple
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 12:30:42 06.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ARCHITECTURE internetExemple OF Lowpass1 IS
    
    
    constant MAC_WIDTH : integer := COEFF_BIT_NB+audioIn'length;
     
    type input_registers is array(0 to FILTER_TAP_NB-1) of signed(audioIn'length-1 downto 0);
    signal areg_s  : input_registers := (others=>(others=>'0'));
     
    type mult_registers is array(0 to FILTER_TAP_NB-1) of signed(audioIn'length+COEFF_BIT_NB-1 downto 0);
    signal mreg_s : mult_registers := (others=>(others=>'0'));
     
    type dsp_registers is array(0 to FILTER_TAP_NB-1) of signed(MAC_WIDTH-1 downto 0);
    signal preg_s : dsp_registers := (others=>(others=>'0'));
     
    signal dout_s : std_logic_vector(MAC_WIDTH-1 downto 0);
    signal sign_s : signed(MAC_WIDTH-audioIn'length-COEFF_BIT_NB+1 downto 0) := (others=>'0');
     
   
    type coefficients is array (0 to FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal breg_s: coefficients:=( 
    x"0183", x"00D7", x"00A5", x"0013", x"FF2D", 
    x"FE1B", x"FD28", x"FCAE", x"FD07", x"FE75", 
    x"010A", x"049E", x"08CD", x"0D08", x"10AB", 
    x"1320", x"13FE", x"1320", x"10AB", x"0D08", 
    x"08CD", x"049E", x"010A", x"FE75", x"FD07",
    x"FCAE", x"FD28", x"FE1B", x"FF2D", 
    x"0013", x"00A5", x"00D7", x"0183");
         
 
begin 
 
 
    audioOut <= preg_s(0)(MAC_WIDTH-2 downto MAC_WIDTH-audioOut'length-1);         
           
     
    process(clock,reset)
    begin
     
    if rising_edge(clock) then
     
        if (reset = '1') then
            for i in 0 to FILTER_TAP_NB-1 loop
                areg_s(i) <=(others=> '0');
                mreg_s(i) <=(others=> '0');
                preg_s(i) <=(others=> '0');
            end loop;
     
        elsif (reset = '0') then       
            for i in 0 to FILTER_TAP_NB-1 loop
                areg_s(i) <= audioIn; 
           
                if (i < FILTER_TAP_NB-1) then
                    mreg_s(i) <= areg_s(i)*breg_s(i);         
                    preg_s(i) <= mreg_s(i) + preg_s(i+1);
                             
                elsif (i = FILTER_TAP_NB-1) then
                    mreg_s(i) <= areg_s(i)*breg_s(i); 
                    preg_s(i)<= mreg_s(i);
                end if;
            end loop; 
        end if;
         
    end if;
    end process;
END ARCHITECTURE internetExemple;

