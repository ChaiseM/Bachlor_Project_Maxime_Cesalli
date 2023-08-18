library Common;
  use Common.CommonLib.all;

ARCHITECTURE Encoder OF lcdCharacterEncoder IS

  constant lcdLineBitNb   : positive := 6;
  constant lcdPageBitNb   : positive := 4;
  constant lcdColumnBitNb : positive := 8;
  

  type fontDisplayStateType is (
    init, idle, readChar, displayColumns
  );
  signal fontDisplayState   : fontDisplayStateType;

  signal asciiColumnCounter : unsigned(requiredBitNb(fontColumnNb)-1 downto 0);
  signal pixelOffset        : unsigned(requiredBitNb(fontColumnNb*fontRowNb-1)-1 downto 0);
  
  signal pageCounter        : unsigned(requiredBitNb(lcdPageNb)-1 downto 0);
  signal columnCounter      : unsigned(requiredBitNb(lcdColumnNb)-1 downto 0);

  signal A0                 : std_ulogic;
  
  signal pixelPage        : std_ulogic_vector(fontRowNb-1 downto 0);
  signal pixelColumnHigh  : std_ulogic_vector(fontRowNb-1 downto 0);
  signal pixelColumnLow   : std_ulogic_vector(fontRowNb-1 downto 0);
  
BEGIN
  ------------------------------------------------------------------------------
                                                                   -- diplay FSM
  fontDisplaySequencer: process(reset, clock)
  begin
    if reset = '1' then
      fontDisplayState <= init;
    elsif rising_edge(clock) then
      case fontDisplayState is
        when init =>
          if lcdBusy = '0' then
            fontDisplayState <= idle;
          end if;
        when idle =>
          if asciiSend = '1' then
            fontDisplayState <= readChar;
          end if;
        when readChar =>
          fontDisplayState <= displayColumns;
        when displayColumns =>
          if (asciiColumnCounter = 0) and (lcdBusy = '0') then
            fontDisplayState <= idle;
          end if;
      end case;
    end if;
  end process fontDisplaySequencer;

  asciiBusy <= '0' when fontDisplayState = idle
    else '1';
  
  a0_proc: process(reset ,clock)
  begin
    if reset = '1' then
      A0 <= '0';
    elsif rising_edge(clock) then
      if asciiSend = '1' then
        if unsigned(asciiData) < 32 then
          A0 <= '0';
        else
          A0 <= '1';
        end if;
      end if;
    end if;
  end process a0_proc;
  

  ------------------------------------------------------------------------------
                                                         -- ascii column counter
  asciiCountColums: process(reset, clock)
  begin
    if reset = '1' then
      asciiColumnCounter <= (others => '0');
    elsif rising_edge(clock) then
      if asciiColumnCounter = 0 then
        if (fontDisplayState = idle) and (asciiSend = '1') then
          asciiColumnCounter <= asciiColumnCounter + 1;
        end if;
      else
        if (fontDisplayState = displayColumns) and (lcdBusy = '0') then
          if asciiColumnCounter < fontColumnNb then
            asciiColumnCounter <= asciiColumnCounter + 1;
          else
            asciiColumnCounter <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process asciiCountColums;
  ------------------------------------------------------------------------------
                                                         -- page, column counter
  counter: process(reset, clock)
  begin
    if reset = '1' then
      pageCounter   <= (others => '0');
      columnCounter <= (others => '0');
      clearDisplay  <= '0';
    elsif rising_edge(clock) then
      clearDisplay <= '0';
      if asciiSend = '1' then
        case to_integer(unsigned(asciiData)) is
          when 2 =>   -- Start of text (home)
            pageCounter   <= (others => '0');
            columnCounter <= (others => '0');
          when 3 =>   -- End of text (end)
            pageCounter   <= to_unsigned(lcdPageNb - 1,pageCounter'length);
            columnCounter <= to_unsigned(lcdColumnNb - fontColumnNb, columnCounter'length);
          when 8 =>    -- BS (backspace) (column back)
            if (columnCounter - fontColumnNb) < 0 then
              columnCounter <= (others => '0');
            else
              columnCounter <= columnCounter - fontColumnNb;
            end if;
          when 10 =>   -- LF (linefeed) (next line)
            if pageCounter = (lcdPageNb-1) then
              pageCounter   <= (others => '0');
            else
              pageCounter   <= pageCounter + 1;
            end if;
          when 11 =>   -- Vertical Tab (prev line)
            if pageCounter = 0 then
              pageCounter   <= to_unsigned(lcdPageNb - 1,pageCounter'length);
            else
              pageCounter   <= pageCounter - 1;
            end if;
          when 13 =>   -- CR (carriage return) (coloumn back)
            columnCounter <= (others => '0');
          when 24 =>   -- CAN (cancel) (clear display)
            clearDisplay <= '1';
          when others =>
            if asciiData >= x"20" then -- normal ascii char
              columnCounter <= columnCounter + fontColumnNb;
            end if;
        end case;
      end if;
    end if;
  end process counter;

  lcdSend <= '1' when
      (fontDisplayState = displayColumns) and
      (lcdBusy = '0') and
      (asciiColumnCounter > 0)
    else '0';
  ------------------------------------------------------------------------------
                                                                     -- Ram Data
  pixelOffset <= resize(
    resize(fontColumnNb-asciiColumnCounter, pixelOffset'length)*fontRowNb,
    pixelOffset'length
  ) when asciiColumnCounter > 0
    else (others => '0');
  pixelPage <= 
    pixelData(
      to_integer(pixelOffset) + fontRowNb-1 downto
      to_integer(pixelOffset) + lcdPageBitNb
    ) &
    std_ulogic_vector(resize(pageCounter,lcdPageBitNb));
  pixelColumnHigh <=
    pixelData(
      to_integer(pixelOffset) + fontRowNb-1 downto
      to_integer(pixelOffset) + (lcdColumnBitNb/2)
    ) &
    std_ulogic_vector(columnCounter(
      columnCounter'high downto (columnCounter'length/2)
    ));
  pixelColumnLow <=
    pixelData(
      to_integer(pixelOffset) + fontRowNb-1 downto
      to_integer(pixelOffset) + (lcdColumnBitNb/2)
    ) &
    std_ulogic_vector(columnCounter(
      (columnCounter'length/2)-1 downto columnCounter'low
    ));

  buildLcdData: process(
    A0, pixelData, pixelOffset,
    pixelPage, pixelColumnHigh, pixelColumnLow
  )
  begin
    lcdData(lcdData'high) <= A0;
    if A0 = '1' then
      lcdData(lcdData'high-1 downto 0) <= pixelData(
        to_integer(pixelOffset)+fontRowNb-1 downto to_integer(pixelOffset)
      );
    elsif pixelOffset >= 40 then
      lcdData(lcdData'high-1 downto 0) <= pixelData(
        to_integer(pixelOffset)+fontRowNb-1 downto to_integer(pixelOffset)
      );
    elsif pixelOffset >= 32 then
      lcdData(lcdData'high-1 downto 0) <= pixelPage;
    elsif pixelOffset >= 24 then
      lcdData(lcdData'high-1 downto 0) <= pixelColumnHigh;
    elsif pixelOffset >= 16 then
      lcdData(lcdData'high-1 downto 0) <= pixelColumnLow;
    else
      lcdData(lcdData'high-1 downto 0) <= pixelData(
        to_integer(pixelOffset)+fontRowNb-1 downto to_integer(pixelOffset)
      );
    end if;
  end process buildLcdData;
  --lcdData <= A0 & pixelData(to_integer(pixelOffset)+fontRowNb-1 downto to_integer(pixelOffset)) when (A0 = '1')
  --      else A0 & pixelData(to_integer(pixelOffset)+fontRowNb-1 downto to_integer(pixelOffset)) when (pixelOffset >= 40)
  --      else A0 & pixelPage                                   when (pixelOffset >= 32)
  --      else A0 & pixelColumnHigh                                 when (pixelOffset >= 24)
  --      else A0 & pixelColumnLow                                when (pixelOffset >= 16)
  --      else A0 & pixelData(to_integer(pixelOffset)+fontRowNb-1 downto to_integer(pixelOffset));
  
END ARCHITECTURE Encoder;
