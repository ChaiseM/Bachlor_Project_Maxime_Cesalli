------------------------------------------------------------------------------
-- Ethernet CRC-32 calculation and verification
--
-- The crcReg register stores the CRC-32 value.
-- The crc register is the most significant 8 bits of the
-- CRC-32 value.
--
-- Function table:
-- |--------+-------------------++---------+-----------+---------|
-- | enable | calculate_shift_n || crcReg  | crc       | crcOk   |
-- |--------+-------------------++---------+-----------+---------|
-- |    0   |          X        || crcReg  | crc       | comp ** |
-- |    1   |          0        || shift   | crcReg *  | crcOk   |
-- |    1   |          1        || nextCrc | nextCrc * | crcOk   |
-- |--------+-------------------++---------+-----------+---------|
--
-- * When the crc output is crcReg or nextCrc, it is bit-swapped
-- and all bits are inverted.
--
-- ** The output crcOk gives the result of the comparison
-- between crcReg and the residue.
-- It is updated only while enable = '0' (at the end the computation).
--
------------------------------------------------------------------------------

ARCHITECTURE RTL OF crc32 IS

  constant residue  : std_ulogic_vector(31 downto 0)
                    := "11000111000001001101110101111011"; -- 0xC704DD7B

  signal nextCrc    : std_ulogic_vector(31 downto 0);
  signal crcReg_int : std_ulogic_vector(31 downto 0);
  signal crc_int    : std_ulogic_vector(7 downto 0);
  signal crcOk_int  : std_ulogic;

BEGIN

  ----------------------------------------------------------------------------
  -- Calculation registers
  ----------------------------------------------------------------------------

  process(clock, reset)
  begin
    if reset = '1' then
      crcReg_int <= ( others => '1' );
      crc_int    <= ( others => '1' );
      crcOk_int  <= '0';
    elsif rising_edge(clock) then
      if init = '1' then
        crcReg_int <= ( others => '1' );
        crc_int    <= ( others => '1' );
        crcOk_int  <= '0';
      elsif enable = '1' then
        if calculate_shift_n = '1' then
          crcReg_int  <= nextCrc;
          crc_int     <= not (nextCrc(24) & nextCrc(25) &
                              nextCrc(26) & nextCrc(27) &
                              nextCrc(28) & nextCrc(29) &
                              nextCrc(30) & nextCrc(31));
        else -- calculate_shift_n = '0'
          crcReg_int  <=  crcReg_int(23 downto 0) & ("11111111");
          crc_int     <= not (crcReg_int(16) & crcReg_int(17) &
                              crcReg_int(18) & crcReg_int(19) &
                              crcReg_int(20) & crcReg_int(21) &
                              crcReg_int(22) & crcReg_int(23));
        end if;
      elsif enable = '0' then
        if unsigned(crcReg_int) = unsigned(residue) then
          crcOk_int <= '1';
        else
          crcOk_int <= '0';
        end if;
      end if;
    end if;
  end process;


  ----------------------------------------------------------------------------
  -- CRC XOR equations
  ----------------------------------------------------------------------------

  nextCrc( 0) <= data(7) XOR crcReg_int(30) XOR crcReg_int(24) XOR data(1);
  nextCrc( 1) <= data(0) XOR data(7) XOR data(6) XOR crcReg_int(30)
                 XOR crcReg_int(24) XOR crcReg_int(25) XOR data(1)
                 XOR crcReg_int(31);
  nextCrc( 2) <= data(0) XOR crcReg_int(24) XOR crcReg_int(25) XOR data(5)
                 XOR data(7) XOR crcReg_int(26) XOR data(6)
                 XOR crcReg_int(30) XOR data(1) XOR crcReg_int(31);
  nextCrc( 3) <= data(0) XOR crcReg_int(27) XOR crcReg_int(25) XOR data(5)
                 XOR crcReg_int(26) XOR data(6) XOR data(4)
                 XOR crcReg_int(31);
  nextCrc( 4) <= crcReg_int(27) XOR crcReg_int(24) XOR data(5) XOR data(3)
                 XOR data(7) XOR crcReg_int(26) XOR crcReg_int(30)
                 XOR data(4) XOR crcReg_int(28) XOR data(1);
  nextCrc( 5) <= data(0) XOR data(2) XOR crcReg_int(27) XOR crcReg_int(24)
                 XOR crcReg_int(25) XOR crcReg_int(29) XOR data(3)
                 XOR data(7) XOR data(6) XOR crcReg_int(30) XOR data(4)
                 XOR crcReg_int(28) XOR data(1) XOR crcReg_int(31);
  nextCrc( 6) <= data(0) XOR data(2) XOR crcReg_int(25) XOR crcReg_int(29)
                 XOR data(5) XOR data(3) XOR crcReg_int(26) XOR data(6)
                 XOR crcReg_int(28) XOR crcReg_int(30) XOR crcReg_int(31)
                 XOR data(1);
  nextCrc( 7) <= data(2) XOR data(0) XOR crcReg_int(27) XOR crcReg_int(24)
                 XOR crcReg_int(29) XOR data(5) XOR data(7)
                 XOR crcReg_int(26) XOR data(4) XOR crcReg_int(31);
  nextCrc( 8) <= crcReg_int(27) XOR crcReg_int(24) XOR crcReg_int(25)
                 XOR crcReg_int(0) XOR data(3) XOR data(7) XOR data(6)
                 XOR data(4) XOR crcReg_int(28);
  nextCrc( 9) <= data(2) XOR crcReg_int(1) XOR crcReg_int(25)
                 XOR crcReg_int(29) XOR data(5) XOR data(3)
                 XOR crcReg_int(26) XOR data(6) XOR crcReg_int(28);
  nextCrc(10) <= data(2) XOR crcReg_int(27) XOR crcReg_int(24)
                 XOR crcReg_int(29) XOR data(5) XOR data(7)
                 XOR crcReg_int(2) XOR crcReg_int(26) XOR data(4);
  nextCrc(11) <= crcReg_int(27) XOR crcReg_int(24) XOR crcReg_int(25)
                 XOR data(3) XOR data(7) XOR data(6) XOR crcReg_int(3)
                 XOR data(4) XOR crcReg_int(28);
  nextCrc(12) <= data(2) XOR crcReg_int(4) XOR crcReg_int(24)
                 XOR crcReg_int(25) XOR crcReg_int(29) XOR data(5)
                 XOR data(3) XOR data(7) XOR crcReg_int(26) XOR data(6)
                 XOR crcReg_int(30) XOR crcReg_int(28) XOR data(1);
  nextCrc(13) <= crcReg_int(5) XOR data(0) XOR data(2) XOR crcReg_int(27)
                 XOR crcReg_int(25) XOR crcReg_int(29) XOR data(5)
                 XOR crcReg_int(26) XOR data(6) XOR data(4)
                 XOR crcReg_int(30) XOR crcReg_int(31) XOR data(1);
  nextCrc(14) <= data(0) XOR crcReg_int(27) XOR data(5) XOR data(3)
                 XOR crcReg_int(26) XOR crcReg_int(6) XOR data(4)
                 XOR crcReg_int(28) XOR crcReg_int(30) XOR data(1)
                 XOR crcReg_int(31);
  nextCrc(15) <= data(2) XOR data(0) XOR crcReg_int(27) XOR crcReg_int(29)
                 XOR data(3) XOR crcReg_int(7) XOR data(4)
                 XOR crcReg_int(28) XOR crcReg_int(31);
  nextCrc(16) <= data(2) XOR crcReg_int(24) XOR crcReg_int(29) XOR data(3)
                 XOR data(7) XOR crcReg_int(8) XOR crcReg_int(28);
  nextCrc(17) <= data(2) XOR crcReg_int(25) XOR crcReg_int(29) XOR data(6)
                 XOR crcReg_int(30) XOR crcReg_int(9) XOR data(1);
  nextCrc(18) <= data(0) XOR crcReg_int(10) XOR data(5) XOR crcReg_int(26)
                 XOR crcReg_int(30) XOR data(1) XOR crcReg_int(31);
  nextCrc(19) <= data(0) XOR crcReg_int(27) XOR crcReg_int(11) XOR data(4)
                 XOR crcReg_int(31);
  nextCrc(20) <= data(3) XOR crcReg_int(12) XOR crcReg_int(28);
  nextCrc(21) <= data(2) XOR crcReg_int(29) XOR crcReg_int(13);
  nextCrc(22) <= crcReg_int(24) XOR data(7) XOR crcReg_int(14);
  nextCrc(23) <= crcReg_int(24) XOR crcReg_int(25) XOR crcReg_int(15)
                 XOR data(7) XOR data(6) XOR crcReg_int(30) XOR data(1);
  nextCrc(24) <= data(0) XOR crcReg_int(25) XOR data(5) XOR crcReg_int(26)
                 XOR data(6) XOR crcReg_int(31) XOR crcReg_int(16);
  nextCrc(25) <= crcReg_int(27) XOR crcReg_int(17) XOR data(5)
                 XOR crcReg_int(26) XOR data(4);
  nextCrc(26) <= crcReg_int(27) XOR crcReg_int(18) XOR crcReg_int(24)
                 XOR data(3) XOR data(7) XOR crcReg_int(30) XOR data(4)
                 XOR crcReg_int(28) XOR data(1);
  nextCrc(27) <= data(0) XOR data(2) XOR crcReg_int(19) XOR crcReg_int(25)
                 XOR crcReg_int(29) XOR data(3) XOR data(6)
                 XOR crcReg_int(28) XOR crcReg_int(31);
  nextCrc(28) <= data(2) XOR crcReg_int(20) XOR crcReg_int(29) XOR data(5)
                 XOR crcReg_int(26) XOR crcReg_int(30) XOR data(1);
  nextCrc(29) <= data(0) XOR crcReg_int(27) XOR crcReg_int(21) XOR data(4)
                 XOR crcReg_int(30) XOR data(1) XOR crcReg_int(31);
  nextCrc(30) <= data(0) XOR crcReg_int(22) XOR data(3) XOR crcReg_int(28)
                 XOR crcReg_int(31);
  nextCrc(31) <= data(2) XOR crcReg_int(29) XOR crcReg_int(23);

  ----------------------------------------------------------------------------
  -- Set outputs
  ----------------------------------------------------------------------------

  crcReg <= crcReg_int;
  crc     <= crc_int;
  crcOk  <= crcOk_int;

END ARCHITECTURE RTL;
