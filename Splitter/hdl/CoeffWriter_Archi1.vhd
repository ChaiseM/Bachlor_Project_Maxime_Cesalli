--
-- VHDL Architecture Splitter.CoeffWriter.Archi1
--
-- Created:
-- by - maxime.cesalli.UNKNOWN (WE2330804)
-- at - 15:22:31 18.07.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE Archi1 OF CoeffWriter IS
   constant HALF_FILTER_TAP_NB : positive := FILTER_TAP_NB/2 + (FILTER_TAP_NB mod 2);
   signal firstWrite : unsigned(3 downto 0);
   signal wAddrCnt : unsigned(addressBitNb - 1 downto 0);
   signal arrayCnt : unsigned(addressBitNb - 1 downto 0);
   signal writeCoeffs : std_ulogic;

   constant n : positive := 1;
   constant initialWAddress : integer := 1024;
   constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) + initialWAddress) - 1);
   -- lowpass firtst then highpass coeff
   type coefficients is array (0 to 1, 0 to HALF_FILTER_TAP_NB - 1) of signed(COEFF_BIT_NB - 1 downto 0);
   signal coeff : coefficients := (
      (
      x"0000210E", x"00005651", x"0000937C", x"0000CFDA", 
      x"0001005A", x"000118E7", x"00010E32", x"0000D7C1", 
      x"000071ED", x"FFFFDF8B", x"FFFF2AE5", x"FFFE65C3", 
      x"FFFDA84C", x"FFFD0EC9", x"FFFCB657", x"FFFCB8E4", 
      x"FFFD28EC", x"FFFE0D79", x"FFFF5F1E", x"0001065E", 
      x"0002DC1E", x"0004AC33", x"00063A34", x"0007481E", 
      x"00079E40", x"00071382", x"000594FA", x"00032BC4", 
      x"00000000", x"FFFC583F", x"FFF894F2", x"FFF527E2", 
      x"FFF28849", x"FFF124A1", x"FFF153B1", x"FFF3469C", 
      x"FFF6FDE0", x"FFFC4306", x"0002A853", x"00098F58", 
      x"0010363B", x"0015CB02", x"00198320", x"001AB4CB", 
      x"0018EF4D", x"00140F24", x"000C4B09", x"00023789", 
      x"FFF6BFAD", x"FFEB127E", x"FFE08662", x"FFD874BD", 
      x"FFD4116E", x"FFD4428C", x"FFD97D46", x"FFE3AC87", 
      x"FFF22577", x"0003AC6C", x"00168B76", x"0028B961", 
      x"00380E4C", x"004280D1", x"00466574", x"0042A905", 
      x"0036FEC9", x"0023FBDD", x"000B1AED", x"FFEEA5C0", 
      x"FFD184D3", x"FFB6F85B", x"FFA240E0", x"FF964013", 
      x"FF951C26", x"FF9FF07A", x"FFB695D6", x"FFD78A90", 
      x"00000000", x"002C0EE8", x"00571015", x"007C1237", 
      x"0096621F", x"00A21776", x"009C969C", x"0084F82E", 
      x"005C4886", x"002594DD", x"FFE5C085", x"FFA32261", 
      x"FF64F10F", x"FF3289DC", x"FF12A3E4", x"FF0A8405", 
      x"FF1D47E7", x"FF4B5D75", x"FF923917", x"FFEC5793", 
      x"0051917B", x"00B7BDE8", x"011399C3", x"0159E109", 
      x"01808101", x"017FC604", x"015365FA", x"00FB4A38", 
      x"007BFFF0", x"FFDEBDB4", x"FF30F615", x"FE837A23", 
      x"FDE9398B", x"FD75B865", x"FD3B5B17", x"FD49AE53", 
      x"FDABD34C", x"FE6736E0", x"FF7AB4F3", x"00DE40A1", 
      x"02831EC8", x"0454B34B", x"0639D473", x"08168B28", 
      x"09CE1C81", x"0B4531B1", x"0C63EFF9", x"0D17D2E4", 
      x"0D551FDA"
      ),
      (
      x"FFFFDEF2", x"FFFFA9AE", x"FFFF6C82", x"FFFF3023", 
      x"FFFEFFA2", x"FFFEE715", x"FFFEF1CA", x"FFFF283C", 
      x"FFFF8E11", x"00002075", x"0000D51E", x"00019A44", 
      x"000257BE", x"0002F143", x"000349B7", x"00034729", 
      x"0002D720", x"0001F28F", x"0000A0E5", x"FFFEF99E", 
      x"FFFD23D6", x"FFFB53BA", x"FFF9C5B3", x"FFF8B7C4", 
      x"FFF861A1", x"FFF8EC62", x"FFFA6AEF", x"FFFCD42F", 
      x"00000000", x"0003A7D0", x"00076B2C", x"000AD84A", 
      x"000D77EE", x"000EDB9B", x"000EAC8B", x"000CB998", 
      x"00090244", x"0003BD09", x"FFFD57A2", x"FFF67081", 
      x"FFEFC983", x"FFEA34A5", x"FFE67C78", x"FFE54AC8", 
      x"FFE7104D", x"FFEBF08A", x"FFF3B4C4", x"FFFDC86E", 
      x"00094078", x"0014EDD7", x"001F7A1F", x"00278BE5", 
      x"002BEF46", x"002BBE26", x"00268358", x"001C53ED", 
      x"000DDAC2", x"FFFC5385", x"FFE9742E", x"FFD745F8", 
      x"FFC7F0CF", x"FFBD7E1F", x"FFB9996C", x"FFBD55EB", 
      x"FFC90056", x"FFDC0390", x"FFF4E4E6", x"00115A86", 
      x"002E7BEB", x"004908D0", x"005DC09F", x"0069C19D", 
      x"006AE58E", x"0060110E", x"00496B56", x"00287615", 
      x"00000000", x"FFD3F064", x"FFA8EE88", x"FF83EBCE", 
      x"FF699B7B", x"FF5DE5F4", x"FF6366E4", x"FF7B05B3", 
      x"FFA3B601", x"FFDA6A89", x"001A3FE7", x"005CDF1A", 
      x"009B116A", x"00CD796B", x"00ED5FE6", x"00F57FE6", 
      x"00E2BBB7", x"00B4A56D", x"006DC8A9", x"0013A8BD", 
      x"FFAE6D38", x"FF483F29", x"FEEC61D8", x"FEA61973", 
      x"FE7F78DD", x"FE8033DD", x"FEAC949C", x"FF04B1C6", 
      x"FF83FE16", x"002142D4", x"00CF0D39", x"017C8BEF", 
      x"0216CEFD", x"028A51FB", x"02C4B037", x"02B65CC1", 
      x"02543637", x"0198CFA5", x"00854D2E", x"FF21BBD3", 
      x"FD7CD6F5", x"FBAB3B05", x"F9C61220", x"F7E953CF", 
      x"F631BB73", x"F4BAA048", x"F39BDD6C", x"F2E7F7A3", 
      x"72AAB301"
      )
   );
begin
   RamWriter : process (clock, reset)
   begin
      if (reset = '1') then
         firstWrite <= (others => '0');
         arrayCnt <= (others => '0');
         wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
         writeCoeffs <= '1';
      elsif rising_edge(clock) then
         if writeCoeffs = '1' then
            wAddrCnt <= wAddrCnt + n;
            addressB <= std_ulogic_vector(wAddrCnt);
            writeEnB <= '1';
            enB <= '1';
            if arrayCnt <= HALF_FILTER_TAP_NB - 1 then
               if firstWrite = 0 then
                  firstWrite <= firstWrite + 1;
                  dataInB <= std_ulogic_vector(unsigned(coeff(1, to_integer(arrayCnt))
                  (COEFF_BIT_NB - 1 downto (COEFF_BIT_NB - (COEFF_BIT_NB/2)))));
               end if;
               if firstWrite = 1 then
                  firstWrite <= firstWrite + 1;
                  dataInB <= std_ulogic_vector(unsigned(coeff(1, to_integer(arrayCnt))
                     ((COEFF_BIT_NB - (COEFF_BIT_NB/2) - 1) downto 0)));
               end if;
               if firstWrite = 2 then
                  firstWrite <= firstWrite + 1;
                  dataInB <= std_ulogic_vector(unsigned(coeff(0, to_integer(arrayCnt))
                  (COEFF_BIT_NB - 1 downto (COEFF_BIT_NB - (COEFF_BIT_NB/2)))));
               end if;
               if firstWrite = 3 then
                  arrayCnt <= arrayCnt + 1;
                  firstWrite <= (others => '0');
                  dataInB <= std_ulogic_vector(unsigned(coeff(0, to_integer(arrayCnt))
                  ((COEFF_BIT_NB - (COEFF_BIT_NB/2) - 1) downto 0)));
               end if;
            end if;
            if arrayCnt = HALF_FILTER_TAP_NB and firstWrite = 0 then
               writeCoeffs <= '0';
               enB <= '0';
               writeEnB <= '0';
               wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
            end if;
         end if;
      end if;
   end process RamWriter;  
END ARCHITECTURE Archi1;