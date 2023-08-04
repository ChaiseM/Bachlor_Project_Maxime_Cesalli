--
-- VHDL Architecture Splitter.Rs232ToRam.a16BitArchi
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 10:18:58 04.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE a16BitArchi OF Rs232ToRam IS
  
   signal firstWrite : unsigned(3 downto 0);
   signal wAddrCnt : unsigned(addressBitNb - 1 downto 0);
   signal arrayCnt : unsigned(addressBitNb - 1 downto 0);
   signal writeCoeffs : std_ulogic;

   constant n : positive := 1;
   constant initialWAddress : integer := 1502;
   
  
begin
   RamWriter : process (clock, reset)
   begin
      if (reset = '1') then
         firstWrite <= (others => '0');
         arrayCnt <= (others => '0');
         wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
         writeCoeffs <= '1';
      elsif rising_edge(clock) then
         if outputEn = '0' then 
            writeCoeffs <= '0';
            writeEnRs <= '0';
            wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
         else
            if newCoeff = '1' then
               wAddrCnt <= wAddrCnt + n;
               addressBRs <= std_ulogic_vector(wAddrCnt);
               writeEnRs <= '1';
              
              
                  if firstWrite = 0 then
                     firstWrite <= firstWrite + 1;
                     dataInBRs <= std_ulogic_vector(unsigned(RS232Coeff
                     (RS232Coeff'length - 1 downto (RS232Coeff'length - (RS232Coeff'length/2)))));
                  end if;
                  if firstWrite = 1 then
                     firstWrite <= (others => '0');
                     dataInBRs <= std_ulogic_vector(unsigned(RS232Coeff
                     ((RS232Coeff'length - (RS232Coeff'length/2) - 1) downto 0)));
                  end if;
            end if;
         end if;
      end if;
   end process RamWriter;  
END ARCHITECTURE a16BitArchi;

