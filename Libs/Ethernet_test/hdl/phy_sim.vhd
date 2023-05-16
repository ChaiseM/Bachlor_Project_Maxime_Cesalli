ARCHITECTURE sim OF miim_phy IS

  constant registerWidth : positive := 16;
  subtype registerType is std_ulogic_vector(registerWidth-1 downto 0);
  constant registerArrayLength : positive := 16;
  type registerArrayType is array (registerArrayLength-1 downto 0) of registerType;
  signal registerArray : registerArrayType;

  signal physicalAddressStored: natural := 1;

  signal shiftRegIn: std_ulogic_vector(31 downto 0);
  signal shiftPosition: natural;

  type deserializerStateType is (
    idle, preamble,
    startOfFrame, readWrite, phyAddr, regAddr, turnAround,
    data
  );
  signal deserializerState: deserializerStateType := idle;

  signal mdC_delayed: std_ulogic;
  signal read_write: boolean;
  signal physicalAddress: unsigned(4 downto 0);
  signal chipSelected: boolean;
  signal registerAddress: unsigned(4 downto 0);
  signal dataIn: std_ulogic_vector(15 downto 0);

  signal startOfPeriod, periodLength: time;
  signal shiftRegOut: std_ulogic_vector(registerWidth+1-1 downto 0);
  signal mdIo_int: std_ulogic := 'H';

BEGIN
  ------------------------------------------------------------------------------
                                                               -- shift register
  shiftDataIn:process(mdC)
  begin
    if rising_edge(mdC) then
      shiftRegIn(shiftRegIn'high downto 1) <= shiftRegIn(shiftRegIn'high-1 downto 0);
      shiftRegIn(0) <= To_X01(mdIo);
    end if;
  end process shiftDataIn;

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  readFsm: process(shiftRegIn, shiftPosition)
  begin
    case deserializerState is
      when idle =>
        if to_integer(signed(shiftRegIn(30 downto 0))) = -1 then
          deserializerState <= preamble;
        end if;
      when preamble =>
        if shiftRegIn(1 downto 0) = "01" then
         deserializerState <= startOfFrame;
        end if;
      when startOfFrame =>
        if shiftPosition = 2 then
          deserializerState <= readWrite;
        end if;
      when readWrite =>
        if shiftPosition = 4 then
          deserializerState <= phyAddr;
        end if;
      when phyAddr =>
        if shiftPosition = 9 then
          deserializerState <= regAddr;
        end if;
      when regAddr =>
        if shiftPosition = 14 then
          deserializerState <= turnAround;
        end if;
      when turnAround =>
        if shiftPosition = 16 then
          deserializerState <= data;
        end if;
      when data =>
        if shiftPosition = 31 then
          deserializerState <= idle after periodLength;
        end if;
      when others => null;
    end case;
  end process readFsm;

  updatePosition: process(deserializerState, mdC)
  begin
    if deserializerState = idle then
      shiftPosition <= 0;
    elsif deserializerState = preamble then
      shiftPosition <= 1;
    elsif rising_edge(mdC) then
      shiftPosition <= shiftPosition + 1;
    end if;
  end process updatePosition;

  ------------------------------------------------------------------------------
                                                                  -- serial data
  mdC_delayed <= mdC after 1 ns;  -- shiftPosition changes on rising edge of mdC

  selectRead_write: process(mdC_delayed)
  begin
    if rising_edge(mdC_delayed) then
      if shiftPosition = 3 then
        if shiftRegIn(1 downto 0) = "10" then
          read_write <= true;
        else
          read_write <= false;
        end if;
      end if;
    end if;
  end process selectRead_write;

  updatePhysicalAddress: process(mdC_delayed)
  begin
   if rising_edge(mdC_delayed) then
      if shiftPosition = 8 then
        physicalAddress <= unsigned(shiftRegIn(physicalAddress'range));
      end if;
    end if;
  end process updatePhysicalAddress;

  chipSelected <= true when physicalAddress = physicalAddressStored else false;

  updateRegisterAddress: process(mdC_delayed)
  begin
    if rising_edge(mdC_delayed) then
      if shiftPosition = 13 then
        registerAddress <= unsigned(shiftRegIn(registerAddress'range));
      end if;
    end if;
  end process updateRegisterAddress;

  readData: process(mdC_delayed)
  begin
    if rising_edge(mdC_delayed) then
      if shiftPosition = 31 then
        dataIn <= shiftRegIn(dataIn'range);
      end if;
    end if;
  end process readData;

  ------------------------------------------------------------------------------
                                                                    -- registers
  updateRegister: process
  begin
    wait until shiftPosition = 31;
    wait until falling_edge(mdC);
    if chipSelected and not read_write then
      registerArray(to_integer(registerAddress)) <= dataIn;
    end if;
  end process updateRegister;

  ------------------------------------------------------------------------------
                                                                     -- data out
  shiftDataOut:process(shiftPosition)
  begin
    if shiftPosition = 14 then
      shiftRegOut <= '0' & registerArray(to_integer(registerAddress));
    elsif shiftPosition >= 14 then
      shiftRegOut(shiftRegOut'high downto 1) <= shiftRegOut(shiftRegOut'high-1 downto 0);
      shiftRegOut(0) <= '1';
    end if;
  end process shiftDataOut;

  measureClockPeriod: process
  begin
    wait until rising_edge(mdc);
    periodLength <= now - startOfPeriod;
    startOfPeriod <= now;
  end process measureClockPeriod;

  driveDataOut:process(shiftRegOut)
  begin
    if read_write and (shiftPosition >= 14) then
      if shiftRegOut(shiftRegOut'high) = '0' then
        mdIo_int <= '0' after periodLength/4;
      else
        mdIo_int <= 'H' after periodLength/4;
      end if;
    else
      mdIo_int <= 'H';
    end if;
  end process driveDataOut;

  mdIo <= mdIo_int;

END ARCHITECTURE sim;
