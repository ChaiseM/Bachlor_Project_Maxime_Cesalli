library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc8782 IS

  constant mclkToSamplingRatio: positive := 128;
  constant channelBitNb: positive := 32;
  constant bclkToLrclkRatio: positive := 2*channelBitNb;
  constant mclkToBclkRatio: positive := mclkToSamplingRatio / bclkToLrclkRatio;

  signal BCLK_int, LRCLK_int: std_ulogic := '0';
  signal bclkCounter, lrclkCounter: natural := 0;
  signal dataShiftRegisterL, dataShiftRegisterR: signed(adcBitNb+1-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                                -- clock signals
  process(MCLK, BCLK, LRCLK)
  begin
    if M_S = '0' then
      BCLK_int <= BCLK;
      LRCLK_int <= LRCLK;
    else
      if falling_edge(MCLK) then
        if bclkCounter < mclkToBclkRatio/2-1 then
          bclkCounter <= bclkCounter + 1;
        else
          bclkCounter <= 0;
          BCLK_int <= not BCLK_int;
        end if;
      end if;
      if falling_edge(BCLK) then
        if lrclkCounter < bclkToLrclkRatio/2-1 then
          lrclkCounter <= lrclkCounter + 1;
        else
          lrclkCounter <= 0;
          LRCLK_int <= not LRCLK_int;
        end if;
      end if;
    end if;
  end process;

  driveClocks: process(M_S, BCLK_int, LRCLK_int)
  begin
    if M_S = '0' then
      BCLK <= 'Z';
      LRCLK <= 'Z';
    else
      BCLK <= BCLK_int;
      LRCLK <= LRCLK_int;
    end if;
  end process driveClocks;

  ------------------------------------------------------------------------------
                                                          -- data shift register
  process(LRCLK, BCLK)
  begin
    if falling_edge(LRCLK) then
      dataShiftRegisterL <= to_signed(AINL, dataShiftRegisterL'length);
      dataShiftRegisterR <= to_signed(AINR, dataShiftRegisterR'length);
    elsif falling_edge(BCLK) then
      if LRCLK = '0' then
        dataShiftRegisterL <= shift_left(dataShiftRegisterL, 1);
      else
        dataShiftRegisterR <= shift_left(dataShiftRegisterR, 1);
      end if;
    end if;
  end process;

  DOUT <= dataShiftRegisterL(dataShiftRegisterL'high) when LRCLK = '0'
    else dataShiftRegisterR(dataShiftRegisterR'high);

END ARCHITECTURE sim;
