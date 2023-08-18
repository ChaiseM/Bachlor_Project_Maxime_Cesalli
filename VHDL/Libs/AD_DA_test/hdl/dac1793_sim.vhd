library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF dac1793 IS

  constant channelBitNb: positive := 32;
  constant zeroDetectSampleNb: positive := 1024;

  signal LRCK_delayed: std_ulogic := '0';
  signal conversionBitNb: positive;
  signal bitCounter: integer := 0;
  signal bitCounterValid, leftChannelSelected: boolean;
  signal signalLeft: signed(dacBitNb-1 downto 0);
  signal signalRight: signed(dacBitNb-1 downto 0);

  signal zeroLeftCounter: integer := 0;
  signal zeroRightCounter: integer := 0;

BEGIN

  --============================================================================
                                                -- serial to parallel conversion
  conversionBitNb <= 16 when FMT(1 downto 0) = "00"
    else 20 when FMT = "001"
    else 24;
  LRCK_delayed <= LRCK after 1 ns;
                                                                  -- bit counter
  process(LRCK_delayed, BCK)
  begin
    if rising_edge(LRCK_delayed) or falling_edge(LRCK_delayed) then
      if FMT(2) = '1' then -- I2S
        bitCounter <= conversionBitNb;
      elsif FMT = "011" then -- left-justified
        bitCounter <= conversionBitNb-1;
      else -- right-justified
        bitCounter <= channelBitNb-1;
      end if;
    elsif falling_edge(BCK) then
      bitCounter <= bitCounter - 1;
    end if;
  end process;
                                                          -- bit load conditions
  bitCounterValid <= true when (bitCounter < conversionBitNb) and (bitCounter >= 0)
    else false;
  leftChannelSelected <= true when (LRCK = '0') and (FMT(2) = '1') -- I2S
    else true when (LRCK = '1') and (FMT(2) = '0')
    else false;
                                                                     -- bit load
  process(BCK)
  begin
    if rising_edge(BCK) and bitCounterValid then
      if leftChannelSelected then
        signalLeft(bitCounter) <= data;
      else 
        signalRight(bitCounter) <= data;
      end if;
    end if;
  end process;

  --============================================================================
                                                                 -- output latch
  process(LRCK)
  begin
    if falling_edge(LRCK) then
      VOUTLp <= to_integer(signalLeft);
      VOUTLm <= -to_integer(signalLeft);
      VOUTRp <= to_integer(signalRight);
      VOUTRm <= -to_integer(signalRight);
    end if;
  end process;

  --============================================================================
                                                               -- zero detection
  process(LRCK)
  begin
    if falling_edge(LRCK) then
      if (signalLeft = 0) and (zeroLeftCounter < zeroDetectSampleNb) then
        zeroLeftCounter <= zeroLeftCounter + 1;
      else
        zeroLeftCounter <= 0;
      end if;
      if (signalRight = 0) and (zeroRightCounter < zeroDetectSampleNb) then
        zeroRightCounter <= zeroRightCounter + 1;
      else
        zeroRightCounter <= 0;
      end if;
    end if;
  end process;

  ZEROL <= '1' when zeroLeftCounter = zeroDetectSampleNb
    else '0';
  ZEROR <= '1' when zeroRightCounter = zeroDetectSampleNb
    else '0';

END ARCHITECTURE sim;
