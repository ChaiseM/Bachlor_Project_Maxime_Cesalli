--
-- VHDL Architecture Splitter.RS232_reciver.FromMorse_Labo5
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 09:18:31 02.08.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
library Common;
  use Common.CommonLib.all;
  
ARCHITECTURE FromMorse_Labo5 OF RS232_reciver IS
 signal dividerCounter: unsigned(requiredBitNb(baudRateDivide-1)-1 downto 0);
  signal dividerCounterReset: std_uLogic;
  signal rxDelayed: std_uLogic;
  signal dividerCounterSynchronize: std_uLogic;
  signal rxSample: std_uLogic;
  signal rxShiftReg: std_ulogic_vector(uartDataBitNb-1 downto 0);
  signal rxReceiving: std_uLogic;
  signal rxDataValid: std_uLogic;
  signal rxCounter: unsigned(requiredBitNb(uartDataBitNb)-1 downto 0);

begin

  divide: process(reset, clock)
  begin
    if reset = '1' then
      dividerCounter <= (others => '0');
    elsif rising_edge(clock) then
      if dividerCounterSynchronize = '1' then
        dividerCounter <= to_unsigned(baudRateDivide/2, dividerCounter'length);
      elsif dividerCounterReset = '1' then
        dividerCounter <= (others => '0');
      else
        dividerCounter <= dividerCounter + 1;
      end if;
    end if;
  end process divide;

  endOfCount: process(dividerCounter)
  begin
    if dividerCounter = baudRateDivide-1 then
      dividerCounterReset <= '1';
    else
      dividerCounterReset <= '0';
    end if;
  end process endOfCount;

  delayRx: process(reset, clock)
  begin
    if reset = '1' then
      rxDelayed <= '0';
    elsif rising_edge(clock) then
      rxDelayed <= RxD;
    end if;
  end process delayRx;

  rxSynchronize: process(RxD, rxDelayed)
  begin
    if RxD /= rxDelayed then
      dividerCounterSynchronize <= '1';
    else
      dividerCounterSynchronize <= '0';
    end if;
  end process rxSynchronize;

  rxSample <= dividerCounterReset;

  shiftReg: process(reset, clock)
  begin
    if reset = '1' then
      rxShiftReg <= (others => '0');
    elsif rising_edge(clock) then
      if rxSample = '1' then
        rxShiftReg(rxShiftReg'high-1 downto 0) <= rxShiftReg(rxShiftReg'high downto 1);
        rxShiftReg(rxShiftReg'high) <= RxD;
      end if;
    end if;
  end process shiftReg;

  detectReceive: process(reset, clock)
  begin
    if reset = '1' then
      rxReceiving <= '0';
      rxDataValid <= '0';
    elsif rising_edge(clock) then
      if rxSample = '1' then
        if rxCounter = uartDataBitNb-1 then
          rxDataValid <= '1';
        elsif RxD = '0' then
          rxReceiving <= '1';
        end if;
      elsif rxDataValid = '1' then
        rxReceiving <= '0';
        rxDataValid <= '0';
      end if;
    end if;
  end process detectReceive;

  countRxBitNb: process(reset, clock)
  begin
    if reset = '1' then
      rxCounter <= (others => '0');
    elsif rising_edge(clock) then
      if rxSample = '1' then
        if rxReceiving = '1' then
          rxCounter <= rxCounter + 1;
        else
          rxCounter <= (others => '0');
        end if;
      end if;
    end if;
  end process countRxBitNb;

  RS232Data <= rxShiftReg;
  RS232Valid <= rxDataValid;

END ARCHITECTURE FromMorse_Labo5;

