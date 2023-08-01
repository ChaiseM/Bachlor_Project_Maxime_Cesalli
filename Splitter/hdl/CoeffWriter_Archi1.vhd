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
   constant initialWAddress : integer := 1501;
   constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) + initialWAddress) - 1);
   -- lowpass firtst then highpass coeff
   type coefficients is array (0 to 1, 0 to HALF_FILTER_TAP_NB - 1) of signed(COEFF_BIT_NB - 1 downto 0);
   signal coeff : coefficients := (
      (
      x"FFFFF25F", x"FFFFECE9", x"FFFFE8CC", x"FFFFE6DD", x"FFFFE7C9", 
      x"FFFFEBF3", x"FFFFF362", x"FFFFFDAB", x"000009F4", x"00001700", 
      x"00002348", x"00002D24", x"00003303", x"0000339A", x"00002E1D", 
      x"00002264", x"0000110A", x"FFFFFB6E", x"FFFFE39C", x"FFFFCC2B", 
      x"FFFFB7F0", x"FFFFA9B5", x"FFFFA3DC", x"FFFFA80B", x"FFFFB6E3", 
      x"FFFFCFD3", x"FFFFF10A", x"00001785", x"00003F5A", x"00006409", 
      x"000080FF", x"0000921A", x"00009436", x"0000859D", x"00006664", 
      x"0000388D", x"00000000", x"FFFFC23A", x"FFFF85D3", x"FFFF51D2", 
      x"FFFF2CE8", x"FFFF1C9C", x"FFFF2494", x"FFFF45FC", x"FFFF7F30", 
      x"FFFFCBB0", x"0000246A", x"00008052", x"0000D543", x"00011914", 
      x"000142C0", x"00014B86", x"00012FD9", x"0000F007", x"00009080", 
      x"0000199B", x"FFFF96F7", x"FFFF1660", x"FFFEA66A", x"FFFE54DA", 
      x"FFFE2D05", x"FFFE365C", x"FFFE734F", x"FFFEE0AB", x"FFFF7597", 
      x"00002428", x"0000DAA4", x"00018536", x"0002100D", x"0002698F", 
      x"00028480", x"000259C4", x"0001E993", x"00013BEB", x"00006029", 
      x"FFFF6BCB", x"FFFE7866", x"FFFDA110", x"FFFCFF70", x"FFFCA8C3", 
      x"FFFCAB3F", x"FFFD0C0B", x"FFFDC620", x"FFFECA3D", x"00000000", 
      x"00014811", x"00027F3A", x"00038214", x"000430FB", x"000473C5", 
      x"00043CE4", x"00038B7C", x"00026C3B", x"0000F8AA", x"FFFF5515", 
      x"FFFDAD18", x"FFFC2F34", x"FFFB07CE", x"FFFA5C23", x"FFFA45C9", 
      x"FFFACF3A", x"FFFBF1D7", x"FFFD95C3", x"FFFF939B", x"0001B7FE", 
      x"0003C8A3", x"00058A65", x"0006C7C8", x"00075729", x"00071FED", 
      x"00061E1C", x"000463D5", x"0002186C", x"FFFF7522", x"FFFCBFB3", 
      x"FFFA434C", x"FFF84880", x"FFF70D2E", x"FFF6BD28", x"FFF76C85", 
      x"FFF91447", x"FFFB91D6", x"FFFEA97D", x"00020BCF", x"00055D76", 
      x"000840AC", x"000A5F6C", x"000B7543", x"000B57A1", x"0009FBB7", 
      x"00077918", x"000408AE", x"00000000", x"FFFBC917", x"FFF7D7C6", 
      x"FFF49D69", x"FFF27C59", x"FFF1BC7D", x"FFF2823D", x"FFF4C8FD", 
      x"FFF861D6", x"FFFCF6E2", x"000212F5", x"00072D24", x"000BB6DA", 
      x"000F2B43", x"00111E33", x"0011490D", x"000F9409", x"000C1AC5", 
      x"00072B63", x"00014015", x"FFFAF395", x"FFF4F18F", x"FFEFE498", 
      x"FFEC637C", x"FFEADFFB", x"FFEB98DC", x"FFEE9107", x"FFF38CCE", 
      x"FFFA15ED", x"0001861F", x"0009175A", x"000FF827", x"00156205", 
      x"0018AF82", x"00196F88", x"001773C1", x"0012D839", x"000C0330", 
      x"00039CD4", x"FFFA7F75", x"FFF1A1AB", x"FFE9FC91", x"FFE470B9", 
      x"FFE1ACCD", x"FFE218A8", x"FFE5C75B", x"FFEC71EA", x"FFF57BA6", 
      x"00000000", x"000AE8BF", x"00150A65", x"001D43F9", x"00229ED5", 
      x"00246B0B", x"0022551E", x"001C7278", x"001342EE", x"0007A6C5", 
      x"FFFAC9D0", x"FFEE05A0", x"FFE2BDA7", x"FFDA38F3", x"FFD57DA4", 
      x"FFD53221", x"FFD98790", x"FFE2304A", x"FFEE63C0", x"FFFCEFD3", 
      x"000C5647", x"001AF389", x"00272ADC", x"002F935C", x"003320FF", 
      x"003144EF", x"002A017E", x"001DEF05", x"000E30B3", x"FFFC59E4", 
      x"FFEA465C", x"FFD9E94F", x"FFCD1812", x"FFC5563A", x"FFC3A8B7", 
      x"FFC8751D", x"FFD37103", x"FFE3A3E2", x"FFF77BD7", x"000CF3C2", 
      x"0021C739", x"0033AF15", x"0040A082", x"004707B1", x"0045F7BF", 
      x"003D4A3F", x"002DAA60", x"001889DC", x"00000000", x"FFE695A5", 
      x"FFCF0314", x"FFBBE66A", x"FFAF7A3C", x"FFAB5455", x"FFB033FC", 
      x"FFBDE592", x"FFD33F71", x"FFEE3932", x"000C1BDC", x"0029C6A3", 
      x"0044018A", x"0057D57F", x"0062E0B5", x"00639DEE", x"0059969A", 
      x"004579A2", x"0029136E", x"000726DC", x"FFE32A36", x"FFC0EE60", 
      x"FFA438EC", x"FF905B96", x"FF87D443", x"FF8C0020", x"FF9CEAE0", 
      x"FFB94065", x"FFDE639C", x"0008A9A1", x"0033B422", x"005AE292", 
      x"0079CEF6", x"008CC966", x"009144F5", x"008629DC", x"006C0301", 
      x"00450089", x"0014CD75", x"FFE03AEF", x"FFACC891", x"FF8014F5", 
      x"FF5F44C5", x"FF4E702A", x"FF50266E", x"FF6515FD", x"FF8BE39D", 
      x"FFC13755", x"00000000", x"0041E8D9", x"007FF6ED", x"00B33FA3", 
      x"00D5A65D", x"00E28D9A", x"00D7686A", x"00B41B7B", x"007B2133", 
      x"00316A21", x"FFDDF99D", x"FF894575", x"FF3C6634", x"FF002ADC", 
      x"FEDC26FE", x"FED5D3A4", x"FEEFDAED", x"FF29A302", x"FF7F27DD", 
      x"FFE92C16", x"005DC0DD", x"00D11C8E", x"0136AF1D", x"01825CD8", 
      x"01A9C2F0", x"01A566FC", x"0171B30D", x"010FA375", x"00851168", 
      x"FFDC8E0B", x"FF24CB3D", x"FE6F9A09", x"FDD0908E", x"FD5B7247", 
      x"FD227C08", x"FD34B902", x"FD9C86B0", x"FE5E6A97", x"FF7856EF", 
      x"00E17239", x"028A6B21", x"045E560A", x"064405B3", x"081FC59A", 
      x"09D553BD", x"0B49F181", x"0C6660EC", x"0D18A46D", x"0D555C3F"
      ),
      (
      x"00000DA1", x"00001317", x"00001734", x"00001923", x"00001837", 
      x"0000140D", x"00000C9E", x"00000255", x"FFFFF60C", x"FFFFE900", 
      x"FFFFDCB9", x"FFFFD2DC", x"FFFFCCFD", x"FFFFCC66", x"FFFFD1E3", 
      x"FFFFDD9C", x"FFFFEEF6", x"00000492", x"00001C64", x"000033D5", 
      x"00004810", x"0000564A", x"00005C24", x"000057F5", x"0000491D", 
      x"0000302D", x"00000EF6", x"FFFFE87B", x"FFFFC0A6", x"FFFF9BF7", 
      x"FFFF7F02", x"FFFF6DE6", x"FFFF6BCA", x"FFFF7A63", x"FFFF999D", 
      x"FFFFC773", x"00000000", x"00003DC6", x"00007A2D", x"0000AE2D", 
      x"0000D317", x"0000E363", x"0000DB6B", x"0000BA04", x"000080D0", 
      x"00003450", x"FFFFDB97", x"FFFF7FAF", x"FFFF2ABE", x"FFFEE6ED", 
      x"FFFEBD40", x"FFFEB47B", x"FFFED028", x"FFFF0FF9", x"FFFF6F81", 
      x"FFFFE665", x"00006909", x"0000E9A0", x"00015995", x"0001AB25", 
      x"0001D2FA", x"0001C9A3", x"00018CB0", x"00011F54", x"00008A69", 
      x"FFFFDBD8", x"FFFF255D", x"FFFE7ACB", x"FFFDEFF5", x"FFFD9673", 
      x"FFFD7B82", x"FFFDA63D", x"FFFE166E", x"FFFEC416", x"FFFF9FD7", 
      x"00009435", x"00018799", x"00025EEE", x"0003008E", x"0003573B", 
      x"000354BF", x"0002F3F3", x"000239DF", x"000135C2", x"00000000", 
      x"FFFEB7F0", x"FFFD80C8", x"FFFC7DEE", x"FFFBCF08", x"FFFB8C3D", 
      x"FFFBC31F", x"FFFC7486", x"FFFD93C7", x"FFFF0757", x"0000AAEB", 
      x"000252E7", x"0003D0C9", x"0004F82F", x"0005A3DA", x"0005BA33", 
      x"000530C3", x"00040E27", x"00026A3B", x"00006C65", x"FFFE4803", 
      x"FFFC3760", x"FFFA759E", x"FFF9383C", x"FFF8A8DC", x"FFF8E017", 
      x"FFF9E1E8", x"FFFB9C2E", x"FFFDE795", x"00008ADE", x"0003404B", 
      x"0005BCB1", x"0007B77B", x"0008F2CD", x"000942D3", x"00089376", 
      x"0006EBB4", x"00046E27", x"00015682", x"FFFDF432", x"FFFAA28D", 
      x"FFF7BF59", x"FFF5A09A", x"FFF48AC4", x"FFF4A866", x"FFF6044F", 
      x"FFF886ED", x"FFFBF755", x"00000000", x"000436E6", x"00082835", 
      x"000B6290", x"000D839E", x"000E437B", x"000D7DBB", x"000B36FC", 
      x"00079E25", x"0003091C", x"FFFDED0C", x"FFF8D2E1", x"FFF4492D", 
      x"FFF0D4C6", x"FFEEE1D7", x"FFEEB6FD", x"FFF06C00", x"FFF3E542", 
      x"FFF8D4A1", x"FFFEBFEC", x"00050C68", x"000B0E6B", x"00101B5E", 
      x"00139C78", x"00151FF8", x"00146718", x"00116EEE", x"000C732A", 
      x"0005EA0F", x"FFFE79E2", x"FFF6E8AB", x"FFF007E3", x"FFEA9E08", 
      x"FFE7508D", x"FFE69087", x"FFE88C4D", x"FFED27D2", x"FFF3FCD7", 
      x"FFFC632F", x"00058088", x"000E5E4C", x"00160362", x"001B8F37", 
      x"001E5321", x"001DE746", x"001A3896", x"00138E0A", x"000A8454", 
      x"00000000", x"FFF51747", x"FFEAF5A7", x"FFE2BC19", x"FFDD6140", 
      x"FFDB950A", x"FFDDAAF6", x"FFE38D9A", x"FFECBD1D", x"FFF85940", 
      x"0005362D", x"0011FA55", x"001D4247", x"0025C6F7", x"002A8242", 
      x"002ACDC5", x"00267859", x"001DCFA4", x"00119C35", x"0003102C", 
      x"FFF3A9C1", x"FFE50C87", x"FFD8D53B", x"FFD06CC0", x"FFCCDF20", 
      x"FFCEBB2F", x"FFD5FE9B", x"FFE2110D", x"FFF1CF55", x"0003A61A", 
      x"0015B997", x"0026169A", x"0032E7CF", x"003AA9A3", x"003C5725", 
      x"00378AC2", x"002C8EE2", x"001C5C0D", x"00088424", x"FFF30C46", 
      x"FFDE38DB", x"FFCC510A", x"FFBF5FA5", x"FFB8F87A", x"FFBA086B", 
      x"FFC2B5E6", x"FFD255BC", x"FFE77632", x"00000000", x"00196A4C", 
      x"0030FCCF", x"0044196D", x"00508594", x"0054AB78", x"004FCBD4", 
      x"00421A46", x"002CC074", x"0011C6C4", x"FFF3E42C", x"FFD63976", 
      x"FFBBFE9F", x"FFA82AB6", x"FF9D1F86", x"FF9C624E", x"FFA6699C", 
      x"FFBA8688", x"FFD6ECAB", x"FFF8D929", x"001CD5B8", x"003F117A", 
      x"005BC6DD", x"006FA427", x"00782B75", x"0073FF9B", x"006314E4", 
      x"0046BF71", x"00219C4F", x"FFF75664", x"FFCC4BFD", x"FFA51DA5", 
      x"FF863153", x"FF7336EE", x"FF6EBB62", x"FF79D674", x"FF93FD40", 
      x"FFBAFFA1", x"FFEB3298", x"001FC4FE", x"0053373D", x"007FEABE", 
      x"00A0BADA", x"00B18F6B", x"00AFD928", x"009AE9A5", x"00741C1D", 
      x"003EC885", x"00000000", x"FFBE174F", x"FF800960", x"FF4CC0C9", 
      x"FF2A5A24", x"FF1D72EF", x"FF289818", x"FF4BE4F2", x"FF84DF17", 
      x"FFCE95FD", x"0022064F", x"0076BA43", x"00C39956", x"00FFD489", 
      x"0123D852", x"012A2BA9", x"01102470", x"00D65C7C", x"0080D7D5", 
      x"0016D3DC", x"FFA23F5B", x"FF2EE3EF", x"FEC9519E", x"FE7DA411", 
      x"FE563E11", x"FE5A9A02", x"FE8E4DD2", x"FEF05D2F", x"FF7AEEE8", 
      x"002371E0", x"00DB343F", x"01906506", x"022F6E21", x"02A48C21", 
      x"02DD823F", x"02CB454F", x"026377E0", x"01A1946E", x"0087A8BF", 
      x"FF1E8E4F", x"FD759666", x"FBA1AC98", x"F9BBFE13", x"F7E03F4A", 
      x"F62AB22F", x"F4B6154B", x"F399A68B", x"F2E76375", x"72AAA11B"
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