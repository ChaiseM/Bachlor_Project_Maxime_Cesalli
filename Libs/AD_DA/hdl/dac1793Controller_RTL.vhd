library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF dac1793Controller IS

  constant resetPulseWidth: real := 40.0E-9;
  constant resetCounterLength: positive := integer(resetPulseWidth*clockFrequency) + 1;
  constant resetCounterBitNb: positive := requiredBitNb(resetCounterLength);
  signal resetCounter: unsigned(resetCounterBitNb-1 DOWNTO 0);
  signal resetCounterDone: std_ulogic;

  constant channelBitNb: positive := 32;
  constant sckFrequency: real := 36.864E6;--24.576E6;
  constant sckCountLength: positive := integer(clockFrequency/sckFrequency);
  constant sckCounterBitNb: positive := requiredBitNb(sckCountLength-1);
  signal sckCounter: unsigned(sckCounterBitNb-1 DOWNTO 0);
  signal sckCounterEnd: std_ulogic;
  constant bckCountLength: positive := 3;--2;
  constant bckCounterBitNb: positive := requiredBitNb(bckCountLength-1);
  signal bckCounter: unsigned(bckCounterBitNb-1 DOWNTO 0);
  signal bckCounterEnd: std_ulogic;
  constant lrckCountLength: positive := 2*channelBitNb;
  constant lrckCounterBitNb: positive := requiredBitNb(lrckCountLength-1);
  signal lrckCounter: unsigned(lrckCounterBitNb-1 DOWNTO 0);
  signal lrckCounterEnd: std_ulogic;

  constant msbOffset: natural := 1;
  signal selectLeft: std_ulogic;
  signal shiftRegisterLeft: signed(dacBitNb-1+msbOffset downto 0);
  signal shiftRegisterRight: signed(dacBitNb-1+msbOffset downto 0);

BEGIN

  --============================================================================
                                   -- configuration: 192 kHz, 192 fs, 24-bit I2S
  DEMP <= "00";
  FMT <= "101";
  MUTE <= '0';

  ------------------------------------------------------------------------------
                                                                    -- ADC reset
  countResetDuration: process(clock, reset)
  begin
    if reset = '1' then
      resetCounter <= (others => '0');
    elsif rising_edge(clock) then
      if resetCounterDone = '0' then
        resetCounter <= resetCounter + 1;
      end if;
    end if;
  end process countResetDuration;

  resetCounterDone <= '1' when resetCounter = resetCounterLength
    else '0';

  RST_n <= not '0' when resetCounterDone = '1'
    else not '1';

  --============================================================================
                                                                -- serial clocks
  ------------------------------------------------------------------------------
                                                                          -- SCK
  countSck: process(clock, reset)
  begin
    if reset = '1' then
      sckCounter <= (others => '0');
    elsif rising_edge(clock) then
      if sckCounterEnd = '1' then
        sckCounter <= (others => '0');
      else
        sckCounter <= sckCounter + 1;
      end if;
    end if;
  end process countSck;

  sckCounterEnd <= '1' when sckCounter = sckCountLength-1
    else '0';
  SCK <= sckCounter(sckCounter'high);

  ------------------------------------------------------------------------------
                                                                          -- BCK
                                                        -- TBD: 50% cyclic ratio
  countBck: process(clock, reset)
  begin
    if reset = '1' then
      bckCounter <= (others => '0');
    elsif rising_edge(clock) then
      if sckCounterEnd = '1' then
        if bckCounterEnd = '1' then
          bckCounter <= (others => '0');
        else
          bckCounter <= bckCounter + 1;
        end if;
      end if;
    end if;
  end process countBck;

  bckCounterEnd <= '1' when (bckCounter = bckCountLength-1) and (sckCounterEnd = '1')
    else '0';
  BCK <= bckCounter(bckCounter'high);

  ------------------------------------------------------------------------------
                                                                         -- LRCK
  countLrck: process(clock, reset)
  begin
    if reset = '1' then
      lrckCounter <= (others => '0');
    elsif rising_edge(clock) then
      if bckCounterEnd = '1' then
        if lrckCounterEnd = '1' then
          lrckCounter <= (others => '0');
        else
          lrckCounter <= lrckCounter + 1;
        end if;
      end if;
    end if;
  end process countLrck;

  lrckCounterEnd <= '1' when (lrckCounter = lrckCountLength-1) and (bckCounterEnd = '1')
    else '0';
  selectLeft <= not lrckCounter(lrckCounter'high);
  LRCK <= lrckCounter(lrckCounter'high);
  newSample <= lrckCounterEnd;

  --============================================================================
                                                                -- serial clocks
  loadAndShift: process(clock, reset)
  begin
    if reset = '1' then
      shiftRegisterLeft <= (others => '0');
      shiftRegisterRight <= (others => '0');
    elsif rising_edge(clock) then
      if lrckCounterEnd = '1' then
        shiftRegisterLeft <= resize(amplitudeLeft, shiftRegisterLeft'length);
        shiftRegisterRight <= resize(amplitudeRight, shiftRegisterRight'length);
      elsif bckCounterEnd = '1' then
        if selectLeft = '1' then
          shiftRegisterLeft <= shift_left(shiftRegisterLeft, 1);
        else
          shiftRegisterRight <= shift_left(shiftRegisterRight, 1);
        end if;
      end if;
    end if;
  end process loadAndShift;

  data <= shiftRegisterLeft(shiftRegisterLeft'high) when selectLeft = '1'
    else shiftRegisterRight(shiftRegisterRight'high);

END ARCHITECTURE RTL;
