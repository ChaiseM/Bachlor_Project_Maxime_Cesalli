ARCHITECTURE RTL OF dacInterface IS
  constant sequenceLength: positive := 40;  -- 2 * 20 ck period => 2 us;
  signal sequenceCounter: unsigned(5 downto 0);
  signal shiftRegister: unsigned(bitNb-1 downto 0);
  signal chipSelect: std_ulogic;
  signal serialClock: std_ulogic;
BEGIN

  countSequence: process(reset, clock)
  begin
    if reset = '1' then
      sequenceCounter <= (others => '0');
    elsif rising_edge(clock) then
      if sequenceCounter = 0 then
        if enConv = '1' then
          sequenceCounter <= sequenceCounter + 1;
        end if;
      elsif sequenceCounter < sequenceLength then
        sequenceCounter <= sequenceCounter + 1;
      else
        sequenceCounter <= (others => '0');
      end if;
    end if;
  end process countSequence;

  buildChipSelect: process(sequenceCounter)
  begin
    if sequenceCounter /= 0 then
      chipSelect <= '1';
    else
      chipSelect <= '0';
    end if;
  end process buildChipSelect;

  buildSerialClock: process(sequenceCounter, chipSelect)
  begin
    if sequenceCounter <= 2*bitNb then
      serialClock <= not sequenceCounter(0);
    else
      serialClock <= '0';
    end if;
  end process buildSerialClock;

  dataShiftRegister: process(reset, clock)
  begin
    if reset = '1' then
      shiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      if chipSelect = '0' then
        shiftRegister <= dataIn;
      elsif serialClock = '1' then
        shiftRegister(shiftRegister'high downto 1) <= shiftRegister(shiftRegister'high-1 downto 0);
      end if;
    end if;
  end process dataShiftRegister;

--  CS_n <= not chipSelect;
--  CLK <= serialClock;
--  SDI <= shiftRegister(shiftRegister'high);

  synchronizeOutputs: process(reset, clock)
  begin
    if reset = '1' then
      CS_n <= '1';
      CLK <= '0';
      SDI <= '0';
    elsif rising_edge(clock) then
      CS_n <= not chipSelect;
      CLK <= serialClock;
      SDI <= shiftRegister(shiftRegister'high);
    end if;
  end process synchronizeOutputs;

END RTL;
