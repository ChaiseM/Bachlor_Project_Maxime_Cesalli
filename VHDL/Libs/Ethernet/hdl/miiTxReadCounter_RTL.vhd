ARCHITECTURE RTL OF miiTxReadCounter IS

  signal readAddress_int : unsigned(readAddress'range);

BEGIN
                                                  -- increment RAM write address
  countAddress: process(reset, clock)
  begin
    if reset = '1' then
      readAddress_int <= (others => '0');
    elsif rising_edge(clock) then
      if incrAddress = '1' then
        readAddress_int <= readAddress_int + 1;
      end if;
    end if;
  end process countAddress;

  readAddress <= readAddress_int;
                                                     -- store frame base address
  storeBaseAddress: process(reset, clock)
  begin
    if reset = '1' then
      baseAddress <= (others => '0');
    elsif rising_edge(clock) then
      if storeAddress = '1' then
        baseAddress <= readAddress_int;
      end if;
    end if;
  end process storeBaseAddress;

END ARCHITECTURE RTL;
