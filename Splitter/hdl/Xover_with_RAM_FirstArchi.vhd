--
-- VHDL Architecture Splitter.Xover_with_RAM.FirstArchi
--
-- Created:
--          by - maxim.UNKNOWN (DESKTOP-ADLE19A)
--          at - 12:11:17 12/07/2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE FirstArchi OF Xover_with_RAM IS
 --constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audio_In'length + FINAL_SHIFT  ;  
   
   
    signal debug :signed(ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    -- +1 because it is symetrical we add two samples together
   
    type   t_samples is array (0 to FILTER_TAP_NB-1) of signed (audio_In'range);  -- vector of FILTER_TAP_NB signed elements
    signal samples : t_samples ; 
    signal oldLRCK : std_ulogic;
    
    signal calculate  : unsigned (2 downto 0);
    signal calculatedelayed  : unsigned (2 downto 0);
    signal cnt   : unsigned(FINAL_SHIFT-1 DOWNTO 0);
    signal cnt2 :  unsigned (2 downto 0);
    signal sum_v : signed(audio_In'length downto 0) := (others=>'0');
    signal mul_v1 : signed(audio_In'length+COEFF_BIT_NB downto 0) := (others=>'0');
    signal mul_v2: signed(audio_In'length+COEFF_BIT_NB downto 0) := (others=>'0');
    signal selector :unsigned (2 downto 0);
    --signal accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
-- RAM oriented variables ----------------------------------------------------
    signal firstWrite : std_ulogic;
    signal cntNooffset :  unsigned(dataBitNb downto 0);
    signal firstRead :  unsigned(3 downto 0);
    signal wAddrCnt : unsigned(addressBitNb-1 downto 0);
    signal rAddrCnt_Plus : unsigned(addressBitNb-1 downto 0);
    signal rAddrCnt_Minus : unsigned(addressBitNb-1 downto 0);
    signal initialRAddress : unsigned(addressBitNb-1 downto 0);
    signal RAMfull : std_ulogic;
    signal RAMfulldelayed : std_ulogic;
    constant n: positive := 1 ;     
    constant initialWAddress : natural := 0;
    signal temp1 :  signed (audio_In'range); 
    signal sample1 :  signed (audio_In'range);
    constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) + initialWAddress) -1);     
    
    -- lowpass firtst then highpass coeff
    type coefficients is array (0 to 1,0 to FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=(
    ( 
        x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"0000", 
x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"FFFF", 
x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"0000", 
x"0001", x"0001", x"0001", x"0002", x"0002", x"0001", x"0001", x"0000", x"FFFF", x"FFFF", 
x"FFFF", x"FFFE", x"FFFD", x"FFFD", x"FFFE", x"FFFE", x"FFFF", x"FFFF", x"0000", x"0002", 
x"0003", x"0004", x"0004", x"0004", x"0004", x"0003", x"0001", x"0000", x"FFFF", x"FFFD", 
x"FFFB", x"FFFA", x"FFFA", x"FFFA", x"FFFB", x"FFFD", x"FFFF", x"0000", x"0003", x"0005", 
x"0007", x"0008", x"0008", x"0007", x"0006", x"0003", x"0000", x"FFFE", x"FFFB", x"FFF8", 
x"FFF6", x"FFF5", x"FFF5", x"FFF7", x"FFF9", x"FFFD", x"0000", x"0005", x"0009", x"000C", 
x"000E", x"000F", x"000E", x"000B", x"0007", x"0002", x"FFFD", x"FFF7", x"FFF3", x"FFEF", 
x"FFED", x"FFED", x"FFEF", x"FFF4", x"FFFA", x"0000", x"0007", x"000E", x"0013", x"0017", 
x"0019", x"0017", x"0013", x"000D", x"0005", x"FFFD", x"FFF4", x"FFEB", x"FFE5", x"FFE2", 
x"FFE1", x"FFE4", x"FFEA", x"FFF3", x"FFFE", x"0009", x"0014", x"001D", x"0024", x"0027", 
x"0025", x"0020", x"0017", x"000B", x"FFFE", x"FFEF", x"FFE2", x"FFD8", x"FFD2", x"FFD0", 
x"FFD4", x"FFDC", x"FFE9", x"FFFA", x"000A", x"001B", x"002A", x"0035", x"003B", x"003A", 
x"0033", x"0026", x"0014", x"0000", x"FFEB", x"FFD7", x"FFC6", x"FFBB", x"FFB7", x"FFBB", 
x"FFC7", x"FFD9", x"FFF1", x"000A", x"0024", x"003C", x"004D", x"0057", x"0058", x"0050", 
x"003E", x"0024", x"0006", x"FFE6", x"FFC7", x"FFAD", x"FF9B", x"FF93", x"FF96", x"FFA5", 
x"FFBF", x"FFE1", x"0008", x"002F", x"0054", x"0071", x"0083", x"0088", x"007D", x"0065", 
x"0041", x"0013", x"FFE2", x"FFB2", x"FF87", x"FF68", x"FF57", x"FF59", x"FF6C", x"FF91", 
x"FFC4", x"0000", x"003F", x"007B", x"00AD", x"00CE", x"00DB", x"00D1", x"00AF", x"0077", 
x"0030", x"FFDF", x"FF8C", x"FF41", x"FF06", x"FEE2", x"FEDC", x"FEF5", x"FF2E", x"FF82", 
x"FFEA", x"005C", x"00CE", x"0133", x"017E", x"01A5", x"01A1", x"016E", x"010D", x"0084", 
x"FFDD", x"FF26", x"FE72", x"FDD3", x"FD5E", x"FD25", x"FD37", x"FD9E", x"FE60", x"FF79", 
x"00E1", x"0289", x"045D", x"0643", x"081E", x"09D4", x"0B49", x"0C66", x"0D18", x"0D55", 
x"0D18", x"0C66", x"0B49", x"09D4", x"081E", x"0643", x"045D", x"0289", x"00E1", x"FF79", 
x"FE60", x"FD9E", x"FD37", x"FD25", x"FD5E", x"FDD3", x"FE72", x"FF26", x"FFDD", x"0084", 
x"010D", x"016E", x"01A1", x"01A5", x"017E", x"0133", x"00CE", x"005C", x"FFEA", x"FF82", 
x"FF2E", x"FEF5", x"FEDC", x"FEE2", x"FF06", x"FF41", x"FF8C", x"FFDF", x"0030", x"0077", 
x"00AF", x"00D1", x"00DB", x"00CE", x"00AD", x"007B", x"003F", x"0000", x"FFC4", x"FF91", 
x"FF6C", x"FF59", x"FF57", x"FF68", x"FF87", x"FFB2", x"FFE2", x"0013", x"0041", x"0065", 
x"007D", x"0088", x"0083", x"0071", x"0054", x"002F", x"0008", x"FFE1", x"FFBF", x"FFA5", 
x"FF96", x"FF93", x"FF9B", x"FFAD", x"FFC7", x"FFE6", x"0006", x"0024", x"003E", x"0050", 
x"0058", x"0057", x"004D", x"003C", x"0024", x"000A", x"FFF1", x"FFD9", x"FFC7", x"FFBB", 
x"FFB7", x"FFBB", x"FFC6", x"FFD7", x"FFEB", x"0000", x"0014", x"0026", x"0033", x"003A", 
x"003B", x"0035", x"002A", x"001B", x"000A", x"FFFA", x"FFE9", x"FFDC", x"FFD4", x"FFD0", 
x"FFD2", x"FFD8", x"FFE2", x"FFEF", x"FFFE", x"000B", x"0017", x"0020", x"0025", x"0027", 
x"0024", x"001D", x"0014", x"0009", x"FFFE", x"FFF3", x"FFEA", x"FFE4", x"FFE1", x"FFE2", 
x"FFE5", x"FFEB", x"FFF4", x"FFFD", x"0005", x"000D", x"0013", x"0017", x"0019", x"0017", 
x"0013", x"000E", x"0007", x"0000", x"FFFA", x"FFF4", x"FFEF", x"FFED", x"FFED", x"FFEF", 
x"FFF3", x"FFF7", x"FFFD", x"0002", x"0007", x"000B", x"000E", x"000F", x"000E", x"000C", 
x"0009", x"0005", x"0000", x"FFFD", x"FFF9", x"FFF7", x"FFF5", x"FFF5", x"FFF6", x"FFF8", 
x"FFFB", x"FFFE", x"0000", x"0003", x"0006", x"0007", x"0008", x"0008", x"0007", x"0005", 
x"0003", x"0000", x"FFFF", x"FFFD", x"FFFB", x"FFFA", x"FFFA", x"FFFA", x"FFFB", x"FFFD", 
x"FFFF", x"0000", x"0001", x"0003", x"0004", x"0004", x"0004", x"0004", x"0003", x"0002", 
x"0000", x"FFFF", x"FFFF", x"FFFE", x"FFFE", x"FFFD", x"FFFD", x"FFFE", x"FFFF", x"FFFF", 
x"FFFF", x"0000", x"0001", x"0001", x"0002", x"0002", x"0001", x"0001", x"0001", x"0000", 
x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", 
x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF"
   ),
   ( 
   x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", 
x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"0000", 
x"0000", x"0000", x"0001", x"0001", x"0001", x"0001", x"0000", x"0000", x"0000", x"FFFF", 
x"FFFF", x"FFFF", x"FFFF", x"FFFE", x"FFFE", x"FFFF", x"FFFF", x"FFFF", x"0000", x"0001", 
x"0001", x"0002", x"0003", x"0003", x"0002", x"0002", x"0001", x"0000", x"FFFF", x"FFFE", 
x"FFFD", x"FFFC", x"FFFC", x"FFFC", x"FFFC", x"FFFD", x"FFFF", x"0000", x"0001", x"0003", 
x"0005", x"0006", x"0006", x"0006", x"0005", x"0003", x"0001", x"FFFF", x"FFFD", x"FFFB", 
x"FFF9", x"FFF8", x"FFF8", x"FFF9", x"FFFA", x"FFFD", x"FFFF", x"0002", x"0005", x"0008", 
x"000A", x"000B", x"000B", x"0009", x"0007", x"0003", x"FFFF", x"FFFB", x"FFF7", x"FFF4", 
x"FFF2", x"FFF1", x"FFF2", x"FFF5", x"FFF9", x"FFFE", x"0003", x"0009", x"000D", x"0011", 
x"0013", x"0013", x"0011", x"000C", x"0006", x"0000", x"FFF9", x"FFF2", x"FFED", x"FFE9", 
x"FFE7", x"FFE9", x"FFED", x"FFF3", x"FFFB", x"0003", x"000C", x"0015", x"001B", x"001E", 
x"001F", x"001C", x"0016", x"000D", x"0002", x"FFF7", x"FFEC", x"FFE3", x"FFDC", x"FFD9", 
x"FFDB", x"FFE0", x"FFE9", x"FFF5", x"0002", x"0011", x"001E", x"0028", x"002E", x"0030", 
x"002C", x"0024", x"0017", x"0006", x"FFF6", x"FFE5", x"FFD6", x"FFCB", x"FFC5", x"FFC6", 
x"FFCD", x"FFDA", x"FFEC", x"0000", x"0015", x"0029", x"003A", x"0045", x"0049", x"0045", 
x"0039", x"0027", x"000F", x"FFF6", x"FFDC", x"FFC4", x"FFB3", x"FFA9", x"FFA8", x"FFB0", 
x"FFC2", x"FFDC", x"FFFA", x"001A", x"0039", x"0053", x"0065", x"006D", x"006A", x"005B", 
x"0041", x"001F", x"FFF8", x"FFD1", x"FFAC", x"FF8F", x"FF7D", x"FF78", x"FF83", x"FF9B", 
x"FFBF", x"FFED", x"001E", x"004E", x"0079", x"0098", x"00A9", x"00A7", x"0094", x"006F", 
x"003C", x"0000", x"FFC1", x"FF85", x"FF53", x"FF32", x"FF25", x"FF2F", x"FF51", x"FF89", 
x"FFD0", x"0021", x"0074", x"00BF", x"00FA", x"011E", x"0124", x"010B", x"00D2", x"007E", 
x"0016", x"FFA4", x"FF32", x"FECD", x"FE82", x"FE5B", x"FE5F", x"FE92", x"FEF3", x"FF7C", 
x"0023", x"00DA", x"018E", x"022D", x"02A2", x"02DB", x"02C9", x"0262", x"01A0", x"0087", 
x"FF1F", x"FD77", x"FBA3", x"F9BD", x"F7E2", x"F62C", x"F4B7", x"F39A", x"F2E8", x"72AA", 
x"F2E8", x"F39A", x"F4B7", x"F62C", x"F7E2", x"F9BD", x"FBA3", x"FD77", x"FF1F", x"0087", 
x"01A0", x"0262", x"02C9", x"02DB", x"02A2", x"022D", x"018E", x"00DA", x"0023", x"FF7C", 
x"FEF3", x"FE92", x"FE5F", x"FE5B", x"FE82", x"FECD", x"FF32", x"FFA4", x"0016", x"007E", 
x"00D2", x"010B", x"0124", x"011E", x"00FA", x"00BF", x"0074", x"0021", x"FFD0", x"FF89", 
x"FF51", x"FF2F", x"FF25", x"FF32", x"FF53", x"FF85", x"FFC1", x"0000", x"003C", x"006F", 
x"0094", x"00A7", x"00A9", x"0098", x"0079", x"004E", x"001E", x"FFED", x"FFBF", x"FF9B", 
x"FF83", x"FF78", x"FF7D", x"FF8F", x"FFAC", x"FFD1", x"FFF8", x"001F", x"0041", x"005B", 
x"006A", x"006D", x"0065", x"0053", x"0039", x"001A", x"FFFA", x"FFDC", x"FFC2", x"FFB0", 
x"FFA8", x"FFA9", x"FFB3", x"FFC4", x"FFDC", x"FFF6", x"000F", x"0027", x"0039", x"0045", 
x"0049", x"0045", x"003A", x"0029", x"0015", x"0000", x"FFEC", x"FFDA", x"FFCD", x"FFC6", 
x"FFC5", x"FFCB", x"FFD6", x"FFE5", x"FFF6", x"0006", x"0017", x"0024", x"002C", x"0030", 
x"002E", x"0028", x"001E", x"0011", x"0002", x"FFF5", x"FFE9", x"FFE0", x"FFDB", x"FFD9", 
x"FFDC", x"FFE3", x"FFEC", x"FFF7", x"0002", x"000D", x"0016", x"001C", x"001F", x"001E", 
x"001B", x"0015", x"000C", x"0003", x"FFFB", x"FFF3", x"FFED", x"FFE9", x"FFE7", x"FFE9", 
x"FFED", x"FFF2", x"FFF9", x"0000", x"0006", x"000C", x"0011", x"0013", x"0013", x"0011", 
x"000D", x"0009", x"0003", x"FFFE", x"FFF9", x"FFF5", x"FFF2", x"FFF1", x"FFF2", x"FFF4", 
x"FFF7", x"FFFB", x"FFFF", x"0003", x"0007", x"0009", x"000B", x"000B", x"000A", x"0008", 
x"0005", x"0002", x"FFFF", x"FFFD", x"FFFA", x"FFF9", x"FFF8", x"FFF8", x"FFF9", x"FFFB", 
x"FFFD", x"FFFF", x"0001", x"0003", x"0005", x"0006", x"0006", x"0006", x"0005", x"0003", 
x"0001", x"0000", x"FFFF", x"FFFD", x"FFFC", x"FFFC", x"FFFC", x"FFFC", x"FFFD", x"FFFE", 
x"FFFF", x"0000", x"0001", x"0002", x"0002", x"0003", x"0003", x"0002", x"0001", x"0001", 
x"0000", x"FFFF", x"FFFF", x"FFFF", x"FFFE", x"FFFE", x"FFFF", x"FFFF", x"FFFF", x"FFFF", 
x"0000", x"0000", x"0000", x"0001", x"0001", x"0001", x"0001", x"0000", x"0000", x"0000", 
x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"0000", 
x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000"
   )
   );
begin 

    
    
    shiftSamplesAndMul : process(clock,reset)
        
        variable accumulator1 : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
        variable accumulator2 : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin        
        if (reset = '1') then
            samples <= (others =>(others => '0'));
            cnt <= (others => '0');
            cnt2 <= (others => '0');
            calculate <= (others => '0');
            calculatedelayed <= (others => '0');
            oldLRCK <= '0';
            selector <= (others => '0');
            wAddrCnt <= to_unsigned(initialWAddress,wAddrCnt'length);
            firstWrite <= '0';
            firstRead <= (others => '0');
            RAMfull <= '0';
            RAMfulldelayed <= '0';
            cntNooffset <= (others => '0');
        elsif rising_edge(clock) then  
            
            we <= '0';
            if en = '1' then
                
                firstWrite <= '1';
                initialRAddress <= ((wAddrCnt+(2*n)- initialWAddress));
           
                wAddrCnt <= wAddrCnt + n;
                we <= '1';
                din <= std_ulogic_vector(unsigned(audio_In(audio_In'length-1 downto (audio_In'length-(audio_In'length/2)))));
                wraddr <= std_ulogic_vector(wAddrCnt);
                
            end if;
           
            if firstWrite = '1' then 
                calculate <= to_unsigned(1,calculate'length);
                cntNooffset   <= (others => '0');   
                firstWrite <= '0';
                wAddrCnt <= wAddrCnt + n;
                
                rAddrCnt_Plus <= initialRAddress;
                rdaddr <= std_ulogic_vector(initialRAddress); 
                if wAddrCnt >= RAMLength then
                    RAMfull <= '1';
                
                    wAddrCnt <= to_unsigned(initialWAddress,wAddrCnt'length);
                end if;
                RAMfulldelayed <= RAMfull;
                we <= '1';
                din <= std_ulogic_vector(unsigned(audio_In((audio_In'length-(audio_In'length/2)-1) downto 0)));
                wraddr <= std_ulogic_vector(wAddrCnt);
            end if ; 
            
            calculatedelayed <= calculate;
            re <= '0';
           
         
            
            if calculatedelayed > 0  and RAMfull = '1' then 
                
                re <= '1';
                if cntNooffset < 5 then 
                    sample1 <= (others => '0');
                    cnt <= (others => '0');
                end if ;
                if cntNooffset >= RAMLength + 2 then 
                    calculate <= calculate-1;   
                    cntNooffset   <= (others => '0');   
                    lowPass <= resize(shift_right(accumulator1,ACCUMULATOR_Bit_NB-Lowpass'length-10),Lowpass'length);
                    Highpass <= resize(shift_right(accumulator2,ACCUMULATOR_Bit_NB-Lowpass'length-10),Lowpass'length);
                    cnt <= (others => '0');  
                    accumulator1 := (others => '0'); 
                    accumulator2 := (others => '0');  
                else
                    cntNooffset <= cntNooffset + 1; 
                end if;
                rdaddr <= std_ulogic_vector(rAddrCnt_Plus); 
                if (rAddrCnt_Plus mod 2) = 0 then 
                    rAddrCnt_Plus <= rAddrCnt_Plus + 1;
                    firstRead <= firstRead +1;
                    temp1(temp1'length-1 downto (temp1'length-(temp1'length/2))) <= signed(dout1);
                    sample1 <= temp1; 
                end if;
                if (rAddrCnt_Plus mod 2 = 1)  then 
                    rAddrCnt_Plus <= rAddrCnt_Plus + 1;
                    firstRead <= (others => '0');
                    temp1((temp1'length-(temp1'length/2)-1) downto 0)  <= signed(dout1);
                   
                end if;
              
              
                
                if rAddrCnt_Plus >= RAMLength then     
                    rAddrCnt_Plus  <= to_unsigned(initialWAddress,wAddrCnt'length);
                end if;
                
                if cntNooffset >= 5  and (cntNooffset mod 2) = 1 then 
                
                    cnt <= cnt+1;
                    accumulator1 := accumulator1 + sample1 * coeff(0,to_integer(cnt));
                    accumulator2 := accumulator2 + sample1 * coeff(1,to_integer(cnt));
                
                end if;
                
                

            
                   
            end if;
           
            
        end if ;
    end process shiftSamplesAndMul;
    
     DataReady <= '1' when calculate = 0 else '0';
     DebugData(1) <= '0'; 
     DebugData(0) <= '0'; 
     

    
     
END ARCHITECTURE FirstArchi;

