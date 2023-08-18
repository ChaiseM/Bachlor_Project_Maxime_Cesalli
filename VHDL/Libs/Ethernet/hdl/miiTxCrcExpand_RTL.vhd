ARCHITECTURE RTL OF miiTxCrcExpand IS

  signal crcDataBuffered : std_ulogic_vector(crcData'range);

BEGIN
  ------------------------------------------------------------------------------
                                  -- Dead time at power-on and end of frame data
  bufferCrc: process(reset, clock)
  begin
    if reset = '1' then
      crcDataBuffered <= (others => '0');
    elsif rising_edge(clock) then
      if crcDataValid = '0' then
        crcDataBuffered <= crcData;
      end if;
    end if;
  end process bufferCrc;

  miiCrc <= crcDataBuffered(crcDataBuffered'high downto crcDataBuffered'high-miiCrc'length+1)
    when crcDataValid = '1'
    else crcData(miiCrc'range);

END ARCHITECTURE RTL;
