--
-- VHDL Architecture Splitter.CoeffWriter.Archi1
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 15:22:31 18.07.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE Archi1 OF CoeffWriter is

    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
    signal firstWrite :  unsigned(3 downto 0);
    signal wAddrCnt : unsigned(addressBitNb-1 downto 0);
    signal arrayCnt : unsigned(addressBitNb-1 downto 0);
    
    signal writeCoeffs : std_ulogic;
    
    
    constant n: positive := 1 ;     
    constant initialWAddress : integer := 1024;

    constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) + initialWAddress) -1);     
    -- lowpass firtst then highpass coeff
    type coefficients is array (0 to 1,0 to HALF_FILTER_TAP_NB-1) of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=(
    ( 
    x"FFFFF398", x"FFFFDCDB", x"FFFFC5DE", x"FFFFB1BE", x"FFFFA3BE", 
    x"FFFF9ED7", x"FFFFA548", x"FFFFB826", x"FFFFD710", x"00000000", 
    x"00002F5A", x"00006029", x"00008C94", x"0000AE7F", x"0000C04E", 
    x"0000BDA8", x"0000A42D", x"000073FC", x"00003003", x"FFFFDDF5", 
    x"FFFF85E4", x"FFFF3191", x"FFFEEB6A", x"FFFEBD56", x"FFFEAF75", 
    x"FFFEC6F6", x"FFFF0527", x"FFFF66E3", x"FFFFE481", x"00007245", 
    x"00010162", x"00018167", x"0001E209", x"00021516", x"0002104C", 
    x"0001CEF2", x"000152E2", x"0000A4EF", x"FFFFD47B", x"FFFEF641", 
    x"FFFE2269", x"FFFD7201", x"FFFCFC31", x"FFFCD35F", x"FFFD02AE", 
    x"FFFD8C19", x"FFFE6779", x"FFFF82A6", x"0000C2BA", x"0002067C", 
    x"000329A7", x"000408D4", x"0004859C", x"00048A69", x"00040D9B", 
    x"00031380", x"0001AEE6", x"00000000", x"FFFE31BB", x"FFFC75A7", 
    x"FFFAFECF", x"FFF9FC14", x"FFF9928F", x"FFF9D8B5", x"FFFAD2CD", 
    x"FFFC7138", x"FFFE90D9", x"0000FDBA", x"000377CD", x"0005B94A", 
    x"00077E2E", x"00088BF6", x"0008B8CF", x"0007F159", x"00063C3C", 
    x"0003BB0C", x"0000A839", x"FFFD520C", x"FFFA131E", x"FFF748FD", 
    x"FFF549E5", x"FFF45AB0", x"FFF4A61C", x"FFF6367F", x"FFF8F2B3", 
    x"FFFC9ED2", x"0000E0DE", x"00054905", x"00095CD1", x"000CA42D", 
    x"000EB6DB", x"000F48ED", x"000E34CA", x"000B8177", x"00076447", 
    x"00023D7A", x"FFFC8FEA", x"FFF6F468", x"FFF20A00", x"FFEE64B6", 
    x"FFEC7C8B", x"FFEC9EBB", x"FFEEE2F8", x"FFF325FF", x"FFF90A69", 
    x"00000000", x"0007510E", x"000E3480", x"0013E31C", x"0017AD8E", 
    x"001910F7", x"0017C78F", x"0013D361", x"000D819F", x"000565D6", 
    x"FFFC4D25", x"FFF32A71", x"FFEAFD88", x"FFE4B79F", x"FFE1200E", 
    x"FFE0BC71", x"FFE3BECD", x"FFE9FC21", x"FFF2ECB5", x"FFFDB6A6", 
    x"000941F8", x"0014546D", x"001DB264", x"0024416B", x"002728C0", 
    x"0025EC15", x"00207D73", x"001743C4", x"000B14DB", x"FFFD2317", 
    x"FFEEDFF6", x"FFE1D685", x"FFD78142", x"FFD11FF6", x"FFCF9219", 
    x"FFD33A1C", x"FFDBED1B", x"FFE8F14B", x"FFF90C01", x"000A9E66", 
    x"001BCE68", x"002AB7E8", x"0035A128", x"003B2CDC", x"003A8455", 
    x"003374C1", x"00267BD4", x"0014C1B1", x"00000000", x"FFEA5809", 
    x"FFD61BBA", x"FFC58F0A", x"FFBAA825", x"FFB6D566", x"FFBACF95", 
    x"FFC67E04", x"FFD8F03D", x"FFF06EEF", x"000AA335", x"0024D0E9", 
    x"003C1E70", x"004DE2D0", x"0057F1D2", x"0058DDD5", x"005027BD", 
    x"003E5709", x"0024F66B", x"00067426", x"FFE5E84E", x"FFC6C62E", 
    x"FFAC8067", x"FF9A291E", x"FF921889", x"FF95A3AC", x"FFA4EC03", 
    x"FFBECE51", x"FFE0F3D1", x"00080569", x"002FFCD9", x"00548C65", 
    x"007192DD", x"00838FFF", x"00880CB7", x"007DEB77", x"006596F7", 
    x"004108D2", x"0013A57D", x"FFE1EF8C", x"FFB11899", x"FF867A33", 
    x"FF670421", x"FF56AF14", x"FF58031A", x"FF6BBFB5", x"FF90B094", 
    x"FFC3B59E", x"00000000", x"003F803E", x"007B7C12", x"00AD3E1C", 
    x"00CECE27", x"00DB9EED", x"00D11E81", x"00AF18A7", x"0077DE69", 
    x"00302BA3", x"FFDEC9D2", x"FF8BF647", x"FF409885", x"FF055B07", 
    x"FEE1BCCB", x"FEDB33C0", x"FEF477EA", x"FF2D0BFC", x"FF81133D", 
    x"FFE97D6F", x"005C8974", x"00CE96C5", x"01333588", x"017E5E34", 
    x"01A5B495", x"01A1B75A", x"016EBDD6", x"010DA8B2", x"00843054", 
    x"FFDCC41F", x"FF25F73D", x"FE718278", x"FDD2EC8C", x"FD5DF397", 
    x"FD24D8EF", x"FD36B4CA", x"FD9DF7CC", x"FE5F3DD5", x"FF788F73", 
    x"00E12683", x"0289BFB8", x"045D76A3", x"06431DF0", x"081EFA61", 
    x"09D4BE19", x"0B499BBD", x"0C664636", x"0D18B2FC", x"0D557996"
   ),
   ( 
    x"00000C68", x"00002325", x"00003A21", x"00004E41", x"00005C41", 
    x"00006128", x"00005AB7", x"000047D9", x"000028F0", x"00000000", 
    x"FFFFD0A6", x"FFFF9FD8", x"FFFF736E", x"FFFF5183", x"FFFF3FB4", 
    x"FFFF425A", x"FFFF5BD5", x"FFFF8C05", x"FFFFCFFD", x"0000220A", 
    x"00007A1B", x"0000CE6D", x"00011493", x"000142A7", x"00015088", 
    x"00013907", x"0000FAD7", x"0000991C", x"00001B7F", x"FFFF8DBC", 
    x"FFFEFEA0", x"FFFE7E9D", x"FFFE1DFC", x"FFFDEAF0", x"FFFDEFBA", 
    x"FFFE3113", x"FFFEAD21", x"FFFF5B13", x"00002B84", x"000109BC", 
    x"0001DD92", x"00028DF8", x"000303C7", x"00032C98", x"0002FD4A", 
    x"000273E1", x"00019883", x"00007D59", x"FFFF3D48", x"FFFDF989", 
    x"FFFCD662", x"FFFBF737", x"FFFB7A70", x"FFFB75A3", x"FFFBF270", 
    x"FFFCEC88", x"FFFE511E", x"00000000", x"0001CE40", x"00038A50", 
    x"00050123", x"000603DB", x"00066D5F", x"0006273A", x"00052D25", 
    x"00038EBE", x"00016F24", x"FFFF0249", x"FFFC883D", x"FFFA46C5", 
    x"FFF881E6", x"FFF77422", x"FFF74749", x"FFF80EBC", x"FFF9C3D5", 
    x"FFFC44FE", x"FFFF57C9", x"0002ADED", x"0005ECD2", x"0008B6EC", 
    x"000AB5FE", x"000BA531", x"000B59C5", x"0009C967", x"00070D3A", 
    x"00036125", x"FFFF1F25", x"FFFAB70A", x"FFF6A348", x"FFF35BF5", 
    x"FFF1494D", x"FFF0B73D", x"FFF1CB5D", x"FFF47EA8", x"FFF89BCD", 
    x"FFFDC28C", x"0003700D", x"00090B80", x"000DF5DA", x"00119B1A", 
    x"00138341", x"00136111", x"00111CD9", x"000CD9DE", x"0006F584", 
    x"00000000", x"FFF8AF06", x"FFF1CBA6", x"FFEC1D1A", x"FFE852B2", 
    x"FFE6EF4D", x"FFE838B1", x"FFEC2CD5", x"FFF27E86", x"FFFA9A38", 
    x"0003B2D1", x"000CD56D", x"0015023F", x"001B4818", x"001EDF9E", 
    x"001F433B", x"001C40E6", x"001603A3", x"000D1328", x"00024954", 
    x"FFF6BE21", x"FFEBABCA", x"FFE24DEC", x"FFDBBEF7", x"FFD8D7AA", 
    x"FFDA1452", x"FFDF82E5", x"FFE8BC7B", x"FFF4EB43", x"0002DCE1", 
    x"00111FDC", x"001E2929", x"00287E50", x"002EDF8C", x"00306D64", 
    x"002CC56B", x"00241284", x"00170E77", x"0006F3EC", x"FFF561B7", 
    x"FFE431E3", x"FFD5488B", x"FFCA5F6A", x"FFC4D3C4", x"FFC57C49", 
    x"FFCC8BCA", x"FFD98495", x"FFEB3E87", x"00000000", x"0015A7BD", 
    x"0029E3D4", x"003A7058", x"0045571F", x"004929D4", x"00452FB0", 
    x"00398161", x"00270F59", x"000F90E7", x"FFF55CE8", x"FFDB2F7A", 
    x"FFC3E233", x"FFB21E03", x"FFA80F1C", x"FFA7231B", x"FFAFD91C", 
    x"FFC1A9A0", x"FFDB09F9", x"FFF98BEC", x"001A176B", x"00393937", 
    x"00537EB7", x"0065D5CE", x"006DE64D", x"006A5B34", x"005B1306", 
    x"004130FE", x"001F0BDB", x"FFF7FAAD", x"FFD003A9", x"FFAB7480", 
    x"FF8E6E56", x"FF7C7165", x"FF77F4B9", x"FF8215DE", x"FF9A6A1C", 
    x"FFBEF7DE", x"FFEC5AB8", x"001E1023", x"004EE692", x"00798484", 
    x"0098FA41", x"00A94F21", x"00A7FB1F", x"00943EBA", x"006F4E3F", 
    x"003C49BF", x"00000000", x"FFC0806E", x"FF84853C", x"FF52C3B9", 
    x"FF313409", x"FF246365", x"FF2EE3B6", x"FF50E933", x"FF8822DC", 
    x"FFCFD4DF", x"002135D4", x"0074087F", x"00BF6575", x"00FAA252", 
    x"011E402E", x"0124C927", x"010B8542", x"00D2F1C8", x"007EEB6B", 
    x"00168254", x"FFA37787", x"FF316B6A", x"FECCCDB8", x"FE81A5D7", 
    x"FE5A4FE1", x"FE5E4D11", x"FE91460A", x"FEF25A28", x"FF7BD111", 
    x"00233B81", x"00DA0674", x"018E7951", x"022D0D90", x"02A20548", 
    x"02DB1F56", x"02C943AB", x"026201C1", x"01A0BDC3", x"00876F1E", 
    x"FF1EDBDE", x"FD764727", x"FBA2952F", x"F9BCF304", x"F7E11B9B", 
    x"F62B5C85", x"F4B682D2", x"F399DB5C", x"F2E77079", x"72AAABFB"
   )
   );
BEGIN



         
    RamWriter : process(clock,reset)
    begin  
    
        if (reset = '1') then
            firstWrite <= (others => '0');
            arrayCnt <= (others => '0');
            
            wAddrCnt <= to_unsigned(initialWAddress,wAddrCnt'length);
            writeCoeffs <= '1';
        elsif rising_edge(clock) then 
        
            if writeCoeffs = '1' then
            
                wAddrCnt <= wAddrCnt + n;
                addressB <= std_ulogic_vector(wAddrCnt);
                writeEnB <= '1';
                enB <= '1';
               
                    if firstWrite = 0 then
                        firstWrite <= firstWrite + 1 ; 
                        dataInB <= std_ulogic_vector(unsigned(coeff(1,to_integer(arrayCnt))
                        (COEFF_BIT_NB-1 downto (COEFF_BIT_NB-(COEFF_BIT_NB/2)))));
                    end if;
                    if firstWrite = 1 then 
                        firstWrite <= firstWrite +1; 
                        dataInB <= std_ulogic_vector(unsigned(coeff(1,to_integer(arrayCnt))
                        ((COEFF_BIT_NB-(COEFF_BIT_NB/2)-1) downto 0 )));
                    end if;
                    if firstWrite = 2 then
                        firstWrite <= firstWrite + 1 ;      
                        dataInB <= std_ulogic_vector(unsigned(coeff(0,to_integer(arrayCnt))
                        (COEFF_BIT_NB-1 downto (COEFF_BIT_NB-(COEFF_BIT_NB/2)))));
                    end if;
                    if firstWrite = 3 then 
                        arrayCnt <= arrayCnt + 1;
                        firstWrite <= (others => '0');
                        dataInB <= std_ulogic_vector(unsigned(coeff(0,to_integer(arrayCnt))
                        ((COEFF_BIT_NB-(COEFF_BIT_NB/2)-1) downto 0 )));
                    end if;
            
             
                if arrayCnt = 249 and firstWrite = 3 then
                    writeCoeffs <= '0';
                    enB <= '0';     
                    writeEnB <= '0';
                    wAddrCnt <= to_unsigned(initialWAddress,wAddrCnt'length);
                end if;
            
            end if;
        end if; 
        
    end process RamWriter;



END ARCHITECTURE Archi1;

