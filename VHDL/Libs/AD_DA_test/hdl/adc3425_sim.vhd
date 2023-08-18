library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc3425 IS

  constant i2cDataBitNb : positive := 8;
  signal chipAddress: std_ulogic_vector(i2cDataBitNb-1-1 downto 0)
    := "1101" & "000";
  constant Taa: time := 150 ns;  -- output valid from clock

  signal reset: std_ulogic;

  signal sDaIn: std_ulogic;
  signal startCondition: std_ulogic;
  signal stopCondition: std_ulogic;
  signal dataShiftReg: std_ulogic_vector(i2cDataBitNb downto 0);
  signal i2cData: std_ulogic_vector(i2cDataBitNb-1 downto 0);
  signal i2cDataDisplay: std_ulogic_vector(i2cData'range);
  signal bitCounter: unsigned(requiredBitNb(i2cDataBitNb+1)-1 downto 0);
  signal endOfWord: std_ulogic;
  signal isSelected: std_ulogic := '0';

  signal sendAckMoment, sendAck: std_ulogic := '0';

  type stateType is (IDLE, CHIP_ADDR, DATA_WR, DATA_RD);
  signal currentState: stateType;
  signal readWrite: std_ulogic;

  signal configurationReg: std_ulogic_vector(i2cDataBitNb-1 downto 0);
  signal signalSample: signed(2*i2cDataBitNb-1 downto 0);
  signal dataByteId: natural := 0;
  signal dataShiftRegister: signed(i2cDataBitNb-1 downto 0) := (others => '1');

BEGIN

  reset <= '1', '0' after 1 ns;

  ------------------------------------------------------------------------------
                                                           -- SDA and conditions
  sDaIn <= To_X01(sDa);

  startCondition <= '1', '0' after 1 ns when falling_edge(sDaIn) and (sCl /= '0') else '0';
  stopCondition <= '1', '0' after 1 ns when rising_edge(sDaIn) and (sCl /= '0') else '0';
  endOfWord <= '1' after 1 ns when bitCounter = i2cDataBitNb+1 else '0' after 1 ns;

  ------------------------------------------------------------------------------
                                               -- shift register and bit counter
  shiftReg: process(reset, sCl)
  begin
    if reset = '1' then
      dataShiftReg <= (others => '0');
    elsif rising_edge(sCl) then
      dataShiftReg(dataShiftReg'high downto 1) <= dataShiftReg(dataShiftReg'high-1 downto 0);
      dataShiftReg(0) <= sDaIn;
    end if;
  end process shiftReg;

  i2cData <= dataShiftReg(dataShiftReg'high downto dataShiftReg'high-i2cDataBitNb+1);
--  i2cDataDisplay <= i2cData when falling_edge(ackTime);

  countBitNb: process(reset, startCondition, sCl, endOfWord)
  begin
    if reset = '1' then
      bitCounter <= (others => '0');
    elsif startCondition = '1' then
      bitCounter <= (others => '0');
    elsif rising_edge(sCl) then
      bitCounter <= bitCounter + 1;
    elsif endOfWord = '1' then
      bitCounter <= (others => '0');
    end if;
  end process countBitNb;

  isSelected <= '1' when
      falling_edge(sCL) and
      (bitCounter = i2cDataBitNb) and
      (i2cData(i2cData'high-1 downto 0) = chipAddress)
    else '0' when stopCondition = '1';

  ------------------------------------------------------------------------------
                                                            -- I2C state machine
  FSM: process(reset, startCondition, stopCondition, endOfWord)
  begin
    if reset = '1' then
      currentState <= IDLE;
    elsif startCondition = '1' then
      currentState <= CHIP_ADDR;
    elsif stopCondition = '1' then
      currentState <= IDLE;
    else
      case currentState is
        when IDLE =>
          if startCondition = '1' then
            currentState <= CHIP_ADDR;
          end if;
        when CHIP_ADDR =>
          if endOfWord = '1' then
            if isSelected = '1' then
              if readWrite = '1' then
                currentState <= DATA_RD;
              else
                currentState <= DATA_WR;
              end if;
            else
              currentState <= IDLE;
            end if;
          end if;
        when DATA_RD =>
          if (endOfWord = '1') and (sDaIn = '1') then
            currentState <= IDLE;
          end if;
        when others => null;
      end case;
    end if;
  end process FSM;

  readWrite <= dataShiftReg(1);

  ------------------------------------------------------------------------------
                                                                  -- acknowledge
  sendAckMoment <= '1' when falling_edge(sCL) and (bitCounter = i2cDataBitNb)
    else '0' when falling_edge(sCL);

  selectSendAck: process(sendAckMoment)
  begin
    if sendAckMoment = '1' then
      if
        (isSelected = '1') and
        ( (currentState = CHIP_ADDR) or (currentState = DATA_WR) )
      then
        sendAck <= '1';
      end if;
    else
      sendAck <= '0';
    end if;
  end process selectSendAck;

  SDA <= '0' after Taa when sendAck = '1'
    else 'Z' after Taa;

  ------------------------------------------------------------------------------
                                                       -- configuration register
  configurationReg <= i2cData when
    (isSelected = '1') and
    (currentState = DATA_WR) and
    rising_edge(endOfWord);

  ------------------------------------------------------------------------------
                                                                -- sampled value
  signalSample <= to_signed(VINp-Vinm, signalSample'length)
    when rising_edge(isSelected);

  selectOutputData: process(currentState, endOfWord)
  begin
    if currentState = IDLE then
      dataByteId <= 0;
    elsif rising_edge(endOfWord) and (isSelected = '1') then
      dataByteId <= dataByteId + 1;
    end if;
  end process selectOutputData;

  shiftOutputData: process(SCL)
  begin
    if falling_edge(SCL) then
      if (bitCounter = 0) and (currentState = DATA_RD) then
        case dataByteId is
          when 1 => dataShiftRegister <= shift_right(signalSample, i2cDataBitNb)(dataShiftRegister'range);
          when 2 => dataShiftRegister <= signalSample(dataShiftRegister'range);
          when 3 => dataShiftRegister <= signed(configurationReg);
          when others => null;
        end case;
      else
        dataShiftRegister <= shift_left(dataShiftRegister, 1);
        dataShiftRegister(0) <= '1';
      end if;
    end if;
  end process shiftOutputData;

  SDA <= '0' after Taa when
      (currentState = DATA_RD) and
      (dataShiftRegister(dataShiftRegister'high) = '0')
    else 'Z' after Taa;

END ARCHITECTURE sim;
