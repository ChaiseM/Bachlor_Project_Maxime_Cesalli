library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF miimSerDes IS

  signal prescaler: unsigned(requiredBitNb(miimClockDivide)-1 downto 0);
  signal phaseCounter: unsigned(1 downto 0);
  signal rd_wrStored: std_ulogic;
  signal miimClockEnable: std_ulogic;
  signal sendFrame: std_ulogic;
  signal sendPreamble: std_ulogic;
  signal sendData: std_ulogic;

  constant miimSequenceLength : positive :=   4
                                          + miimPhyAddrBitNb
                                          + miimRegAddrBitNb
                                          + 2
                                          + miimDataBitNb;
  signal sequenceCounter: unsigned(requiredBitNb(2*miimSequenceLength+1)-1 downto 0);
  signal sequenceDone: std_ulogic;
  signal shiftRegister: std_ulogic_vector(miimSequenceLength-1 downto 0);
  signal miimInputData: std_ulogic_vector(miimDataBitNb-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                          -- divide clock period
  divideClock: process(reset, clock)
  begin
    if reset = '1' then
      prescaler <= (others => '0');
    elsif rising_edge(clock) then
      if miimClockEnable = '1' then
        prescaler <= (others => '0');
      else
        prescaler <= prescaler + 1;
      end if;
    end if;
  end process divideClock;

  miimClockEnable <= '1' when prescaler >= miimClockDivide-1 else '0';

  countPhases: process(reset, clock)
  begin
    if reset = '1' then
      phaseCounter <= (others => '0');
    elsif rising_edge(clock) then
      if start = '1' then
        phaseCounter <= (others => '0');
      elsif miimClockEnable = '1' then
        phaseCounter <= phaseCounter + 1;
      end if;
    end if;
  end process countPhases;

  ------------------------------------------------------------------------------
                                                          -- store RD/WR control
  srtoeRdWr: process(reset, clock)
  begin
    if reset = '1' then
      rd_wrStored <= '0';
    elsif rising_edge(clock) then
      if start = '1' then
        rd_wrStored <= rd_wr;
      end if;
    end if;
  end process srtoeRdWr;

  ------------------------------------------------------------------------------
                                                            -- build MD sequence
  countSequence: process(reset, clock)
  begin
    if reset = '1' then
      sequenceCounter <= (others => '0');
      sequenceDone <= '0';
    elsif rising_edge(clock) then
      sequenceDone <= '0';
      if sequenceCounter = 0 then
        if start = '1' then
          sequenceCounter <= sequenceCounter + 1;
        end if;
      elsif sequenceCounter < 2*miimSequenceLength+1 then
        if (miimClockEnable = '1') and (phaseCounter = 3) then
          sequenceCounter <= sequenceCounter + 1;
        end if;
      else
        sequenceCounter <= (others => '0');
        sequenceDone <= '1';
      end if;
    end if;
  end process countSequence;

  sendFrame <= '1' when sequenceCounter > 0 else '0';
  sendPreamble <= '1' when (sendFrame = '1') and (sequenceCounter <= 32) else '0';
  sendData <= '1' when sequenceCounter > 32+16-1 else '0';
  done <= sequenceDone;

  shiftData: process(reset, clock)
  begin
    if reset = '1' then
      shiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      if start = '1' then
        shiftRegister(shiftRegister'high downto shiftRegister'high-2+1) <= "01";
        if rd_wr = '1' then
          shiftRegister(shiftRegister'high-2 downto shiftRegister'high-2-2+1) <= "10";
        else
          shiftRegister(shiftRegister'high-2 downto shiftRegister'high-2-2+1) <= "01";
        end if;
        shiftRegister(shiftRegister'high-4 downto shiftRegister'high-4-miimPhyAddrBitNb+1) <= std_ulogic_vector(phyAddr);
        shiftRegister(shiftRegister'high-4-miimPhyAddrBitNb downto shiftRegister'high-4-miimPhyAddrBitNb-miimRegAddrBitNb+1) <= std_ulogic_vector(regAddr);
        shiftRegister(miimDataBitNb+2-1 downto miimDataBitNb) <= "10";
        shiftRegister(dataOut'range) <= dataOut;
      elsif sendPreamble = '0' then
        if (rd_wrStored = '1') and (sendData = '1') then
          if (miimClockEnable = '1') and (phaseCounter = 0) then
            shiftRegister(shiftRegister'high downto 1) <= shiftRegister(shiftRegister'high-1 downto 0);
            shiftRegister(0) <= mdIoIn;
          end if;
        elsif sendFrame = '1' then
          if (miimClockEnable = '1') and (phaseCounter = 0) then
            shiftRegister(shiftRegister'high downto 1) <= shiftRegister(shiftRegister'high-1 downto 0);
            shiftRegister(0) <= '0';
          end if;
        end if;
      end if;
    end if;
  end process shiftData;

  ------------------------------------------------------------------------------
                                                                 -- read MD data
  miimInputData <= shiftRegister(miimInputData'range);

  storeReadbackData: process(reset, clock)
  begin
    if reset = '1' then
      dataIn <= (others => '0');
    elsif rising_edge(clock) then
      if (rd_wrStored = '1') and (sequenceCounter = 2*miimSequenceLength) then
        dataIn <= miimInputData;
      end if;
    end if;
  end process storeReadbackData;

  ------------------------------------------------------------------------------
                                                            -- miim clock signal
  buildClock: process(reset, clock)
  begin
    if reset = '1' then
      mdC <= '0';
    elsif rising_edge(clock) then
      if (sendFrame = '1') and (phaseCounter = 1) then
        mdC <= '1';
      elsif phaseCounter = 3 then
        mdC <= '0';
      end if;
    end if;
  end process buildClock;

  ------------------------------------------------------------------------------
                                                             -- miim serial data
  buildData: process(reset, clock)
  begin
    if reset = '1' then
      mdIoOut <= '0';
    elsif rising_edge(clock) then
      if sendFrame = '0' then
        mdIoOut <= '1';
      elsif sendPreamble = '1' then
        mdIoOut <= '1';
      elsif phaseCounter = 0 then
        if (sendData = '0') or (rd_wrStored = '0') then
          mdIoOut <= shiftRegister(shiftRegister'high);
        else
          mdIoOut <= '1';
        end if;
      end if;
    end if;
  end process buildData;


END ARCHITECTURE RTL;
