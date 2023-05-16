LIBRARY Common;
  USE Common.commonLib.all;

ARCHITECTURE RTL OF txULogicVector IS

  constant txStringLength : positive := txString'length + 1 + hexDigitNb + 1;
  signal txCounter : unsigned(requiredBitNb(txStringLength)-1 downto 0);
  signal binaryValue : unsigned(4*hexDigitNb-1 downto 0);
  type asciiValueType is array(hexDigitNb-1 downto 0) of unsigned(7-1 downto 0);
  signal asciiValue : asciiValueType;

BEGIN
  ------------------------------------------------------------------------------
                                                             -- build hex string
  binaryValue <= resize(unsigned(txValue), binaryValue'length);

  translateToAscii: process(binaryValue)
    variable hexValue : unsigned(4-1 downto 0);
  begin
    for index in asciiValue'range loop
      hexValue := binaryValue(4*index+3 downto 4*index);
      if hexValue < 10 then
        asciiValue(hexDigitNb-index-1) <= "011" & hexValue;
      else
        asciiValue(hexDigitNb-index-1) <= "100" & hexValue-9;
      end if;
    end loop;
  end process translateToAscii;

  ------------------------------------------------------------------------------
                                                          -- count string length
  updateRegister: process(reset, clock)
  begin
    if reset = '1' then
      txCounter <= (others => '0');
    elsif rising_edge(clock) then
      if txCounter = 0 then
        if en = '1' then
          txCounter <= txCounter + 1;
        end if;
      else
        if txFull = '0' then
          if txCounter < txStringLength then
            txCounter <= txCounter + 1;
          else
            txCounter <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process updateRegister;

  ------------------------------------------------------------------------------
                                                     -- select character to send
  slectCharacter :process(txCounter)
  begin
    if txCounter = 0 then
      txData <= (others => '0');
    elsif txCounter <= txString'length then
      txData <= std_ulogic_vector(to_unsigned(
        character'pos(txString(to_integer(txCounter))),
        txData'length
      ));
    elsif txCounter = txString'length+1 then
      txData <= std_ulogic_vector(to_unsigned(character'pos(' '), txData'length));
    elsif txCounter < txStringLength then
      txData <= std_ulogic_vector(resize(
        asciiValue(to_integer(txCounter)-txString'length-2),
        txData'length
      ));
    else
      txData <= std_ulogic_vector(to_unsigned(character'pos(CR), txData'length));
    end if;
  end process slectCharacter;

  ------------------------------------------------------------------------------
                                                                -- write control
  txWr <= not txFull when txCounter > 0
    else '0';

END ARCHITECTURE RTL;
