ARCHITECTURE RTL OF miiRxDataConcat IS

  signal writeData_int : unsigned(writeData'range);

BEGIN

  shiftData: process(reset, clock)
  begin
    if reset = '1' then
      writeData_int <= (others => '0');
    elsif rising_edge(clock) then
      if dataEn = '1' then
        writeData_int <= shift_left(writeData_int, miiData'length);
        writeData_int(miiData'range) <= unsigned(miiData);
      end if;
    end if;
  end process shiftData;

  process(
    initFrame,
    frameOk, framelength,
    frameError, errorCode,
    writeData_int
  )
  begin
    if initFrame = '1' then
      writeData <= (others => '0');
    elsif frameOk = '1' then
      writeData <= (others => '0');
      writeData(framelength'range) <= std_ulogic_vector(framelength);
      writeData(writeData'high) <= '1';
    elsif frameError = '1' then
      writeData <= (others => '0');
      writeData(writeData'high) <= '1';
      writeData(writeData'high-1 downto writeData'high-errorCode'length) <= errorCode;
    else
      writeData <= std_ulogic_vector(writeData_int);
    end if;
  end process;

END ARCHITECTURE RTL;
