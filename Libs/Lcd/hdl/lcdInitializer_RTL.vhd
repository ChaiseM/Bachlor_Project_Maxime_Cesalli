library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF lcdInitializer IS

  constant initializationSequenceLength: positive := 14;
  type initializationDataType is array (1 to initializationSequenceLength+1)
    of std_ulogic_vector(lcdData'range);
  constant initializationData: initializationDataType :=(
    '0' & X"40",    -- Display start line 0
    '0' & X"A1",    -- ADC reverse
    '0' & X"C0",    -- Normal COM0~COM31
    '0' & X"A6",    -- Display normal
    '0' & X"A2",    -- Set bias 1/9 (Duty 1/33)
    '0' & X"2F",    -- Booster, Regulator and Follower on
    '0' & X"F8",    -- Set internal Booster to 3x / 4x
    '0' & X"00",    -- 
    '0' & X"23",    -- Contrast set
    '0' & X"81",    -- 
    '0' & X"1F",    -- 
    '0' & X"AC",    -- No indicator
    '0' & X"00",    -- 
    '0' & X"AF",    -- Display on
    std_ulogic_vector(to_unsigned(0, lcdData'length))
  );

  constant clearDisplaySequenceLength : positive := 566;--(3+132)*4 + 3; -- (3 commands + 132 columns) * 4 pages + jump back to start
  constant clearDisplayDataLength     : positive := 6;
  type clearDisplayDataType is array (1 to clearDisplayDataLength+1)
    of std_ulogic_vector(lcdData'range);
  constant clearDisplayData: clearDisplayDataType :=(
                    --  ind  seq
    '0' & X"B0",    --  1    Page 0
    '0' & X"B1",    --  2    Page 1
    '0' & X"B2",    --  3    Page 2
    '0' & X"B3",    --  4    Page 3
    '0' & X"10",    --  5    Column MSB 0
    '0' & X"00",    --  6    Column LSB 0
    '1' & X"00"     --  7    Data "empty"
  );

  signal initSequenceCounter: unsigned(requiredBitNb(initializationSequenceLength+1)-1 downto 0);
  signal initSequenceDone: std_ulogic;
  signal clearSequenceCounter: unsigned(requiredBitNb(clearDisplaySequenceLength+1)-1 downto 0);
  signal clearSequenceDone: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                              -- initialization sequence counter
  buildInitSequence: process(reset, clock) 
  begin
    if reset='1' then
      initSequenceCounter <= to_unsigned(1, initSequenceCounter'length);
    elsif rising_edge(clock) then
      if lcdBusy = '0' then
        if initSequenceDone = '0' then
          initSequenceCounter <= initSequenceCounter + 1;
        end if;
      end if;
    end if;
  end process buildInitSequence;

  initSequenceDone <= '1' when initSequenceCounter > initializationSequenceLength
    else '0';

  ------------------------------------------------------------------------------
                                                       -- clear sequence counter
  buildClearSequence: process(reset, clock) 
  begin
    if reset='1' then
      clearSequenceCounter <= to_unsigned(clearDisplaySequenceLength+1, clearSequenceCounter'length);
    elsif rising_edge(clock) then
      if lcdBusy = '0' then
        if clearDisplay = '1' and initSequenceDone = '1' then
          clearSequenceCounter <= to_unsigned(1, clearSequenceCounter'length);
        elsif clearSequenceDone = '0' then
          clearSequenceCounter <= clearSequenceCounter + 1;
        end if;
      end if;
    end if;
  end process buildClearSequence;

  clearSequenceDone <= '1' when clearSequenceCounter > clearDisplaySequenceLength
    else '0';

  ------------------------------------------------------------------------------
                                                             -- data multiplexer
  lcdData <= columnData when (initSequenceDone = '1' and clearSequenceDone = '1')
    else initializationData(to_integer(initSequenceCounter)) when (initSequenceCounter > 0 and initSequenceDone = '0')
    else clearDisplayData(1) when (clearSequenceCounter = 1 or clearSequenceCounter = 564)
    else clearDisplayData(2) when (clearSequenceCounter = 137)
    else clearDisplayData(3) when (clearSequenceCounter = 273)
    else clearDisplayData(4) when (clearSequenceCounter = 409)
    else clearDisplayData(5) when (clearSequenceCounter = 2 or clearSequenceCounter = 138 or clearSequenceCounter = 274 or clearSequenceCounter = 410 or clearSequenceCounter = 565)
    else clearDisplayData(6) when (clearSequenceCounter = 3 or clearSequenceCounter = 139 or clearSequenceCounter = 275 or clearSequenceCounter = 411 or clearSequenceCounter = 566)
    else clearDisplayData(7);

  lcdSend <= columnSend when initSequenceDone = '1' and clearSequenceDone = '1'
    else not lcdBusy when initSequenceCounter <= initializationSequenceLength
    else not lcdBusy when clearSequenceCounter <= clearDisplaySequenceLength
    else '0';
  columnBusy <= lcdBusy when initSequenceDone = '1' and clearSequenceDone = '1'
    else '1';

END ARCHITECTURE RTL;
