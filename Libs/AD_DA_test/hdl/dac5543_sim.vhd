ARCHITECTURE sim OF dac5543 IS

  signal serialRegister: unsigned(15 downto 0);

BEGIN

  shiftRegister: process(CLK)
  begin
    if (CS_n = '0') and rising_edge(CLK) then
      serialRegister(serialRegister'high downto 1) <= serialRegister(serialRegister'high-1 downto 0);
      serialRegister(0) <= SDI;
    end if;
  end process shiftRegister;

  dacRegister: process(CS_n)
  begin
    if rising_edge(CS_n) then
      Iout <= to_integer(serialRegister);
    end if;
  end process dacRegister;

END ARCHITECTURE sim;
