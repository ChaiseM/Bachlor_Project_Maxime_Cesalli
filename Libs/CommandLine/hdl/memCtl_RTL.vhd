ARCHITECTURE RTL OF memCtl IS

  signal charIn: std_uLogic_vector(7 downto 0);
  signal wordId: unsigned(1 downto 0);
  signal writeMode: std_ulogic;
  signal memAddr_int: unsigned(addr'range);

BEGIN
                                                  -- count number of values read
  updateWordId: process(reset, clock)
  begin
    if reset = '1' then
      wordId <= (others => '0');
    elsif rising_edge(clock) then
      if endOfCommand = '1' then
        wordId <= (others => '0');
      elsif en = '1' then
        wordId <= wordId + 1;
      end if;
    end if;
  end process updateWordId;
                                                            -- select write mode
  updateWriteMode: process(reset, clock)
  begin
    if reset = '1' then
      writeMode <= '0';
    elsif rising_edge(clock) then
      if wr = '1' then
        writeMode <= '1';
      elsif endOfCommand = '1' then
        writeMode <= '0';
      end if;
    end if;
  end process updateWriteMode;
                                                  -- store and increment address
  addrRegister: process(reset, clock)
  begin
    if reset = '1' then
      memAddr_int <= (others => '0');
    elsif rising_edge(clock) then
      if en = '1' then
        if wordId = 0 then
          memAddr_int <= addr;
        elsif wordId > 1 then
          memAddr_int <= memAddr_int + 1;
        end if;
      end if;
    end if;
  end process addrRegister;

  memAddr <= memAddr_int;
                                                          -- store data to write
  dataRegister: process(reset, clock)
  begin
    if reset = '1' then
      memData <= (others => '0');
    elsif rising_edge(clock) then
      if en = '1' then
        memData <= std_ulogic_vector(data);
      end if;
   end if;
  end process dataRegister;
                                                           -- store access count
  countRegister: process(reset, clock)
  begin
    if reset = '1' then
      accessCount <= (others => '0');
    elsif rising_edge(clock) then
      if rd = '1' then
        accessCount <= count;
      end if;
    end if;
  end process countRegister;
                                                          -- build write control
  delayWr: process(reset, clock)
  begin
    if reset = '1' then
      memWr <= '0';
    elsif rising_edge(clock) then
      memWr <= '0';
      if (en = '1') and (writeMode = '1') then
        if wordId > 0 then
          memWr <= '1';
        end if;
      end if;
    end if;
  end process delayWr;
                                                           -- build read control
  delayRd: process(reset, clock)
  begin
    if reset = '1' then
      memRd <= '0';
    elsif rising_edge(clock) then
      memRd <= rd;
    end if;
  end process delayRd;

END ARCHITECTURE RTL;
