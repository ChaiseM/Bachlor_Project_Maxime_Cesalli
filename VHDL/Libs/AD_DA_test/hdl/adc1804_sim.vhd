library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc1804 IS

  constant bckToSamplingRatio: positive := 128;
  constant channelBitNb: positive := 32;
  constant bckToLrckRatio: positive := 2*channelBitNb;
  signal sckToBckRatio: positive;

  signal BCK_int, LRCK_int: std_ulogic := '0';
  signal BCK_delayed: std_ulogic := '0';
  signal bckCounter, lrckCounter: natural := 0;
  signal dataShiftRegisterL, dataShiftRegisterR: signed(channelBitNb+1-1 downto 0)
    := (others => '0');
  signal formatShiftBitNb: natural := 0;

  signal vInLeft, vInRight: integer;

BEGIN
  ------------------------------------------------------------------------------
                                               -- clock division (in master mode)
  with to_integer(unsigned(OSR)) select
    sckToBckRatio <= 768 / bckToLrckRatio when 0,
                     512 / bckToLrckRatio when 1,
                     384 / bckToLrckRatio when 2,
                     256 / bckToLrckRatio when 3,
                     384 / bckToLrckRatio when 4,
                     256 / bckToLrckRatio when 5,
                     192 / bckToLrckRatio when 6,
                     128 / bckToLrckRatio when others;
                                                                -- clock signals
  process(SCKI, BCK_DSDL, LRCK_DSDBCK, sckToBckRatio)
  begin
    if S_M = '1' then
      BCK_int <= BCK_DSDL;
      LRCK_int <= LRCK_DSDBCK;
    else
      if rising_edge(SCKI) or falling_edge(SCKI) then
        if bckCounter < sckToBckRatio-1 then
          bckCounter <= bckCounter + 1;
        else
          bckCounter <= 0;
          if bck_int = '1' then
            if lrckCounter < bckToLrckRatio/2-1 then
              lrckCounter <= lrckCounter + 1;
            else
              lrckCounter <= 0;
              lrck_int <= not lrck_int;
            end if;
          end if;
          bck_int <= not bck_int;
        end if;
      end if;
    end if;
  end process;

  driveClocks: process(S_M, BCK_int, LRCK_int)
  begin
    if S_M = '1' then
      BCK_DSDL <= 'Z';
      LRCK_DSDBCK <= 'Z';
    else
      BCK_DSDL <= BCK_int;
      LRCK_DSDBCK <= LRCK_int;
    end if;
  end process driveClocks;

  ------------------------------------------------------------------------------
                                                               -- input voltages
                                                   -- HP and bypass to come here
  vInLeft <= VINLp-VINLm;
  vInRight <= VINRp-VINRm;

  OVFL <= '1' when vInLeft > 2**adcBitNb-1
    else '1' when vInLeft < -2**adcBitNb
    else '0';
  OVFR <= '1' when vInRight > 2**adcBitNb-1
    else '1' when vInRight < -2**adcBitNb
    else '0';

  ------------------------------------------------------------------------------
                                        -- data shift bit nb for selected format
  with to_integer(unsigned(FMT)) select
    formatShiftBitNb <= channelBitNb - adcBitNb     when 0,  -- left-justified data format
                        channelBitNb - adcBitNb - 1 when 1,  -- I2S data format
                        0                           when 2,  -- standard PCM (right-justified) data format
                        0                           when others;

  ------------------------------------------------------------------------------
                                                          -- data shift register
  BCK_delayed <= BCK_DSDL after 1 ns;

  loadOrShift: process(LRCK_DSDBCK, BCK_delayed)
  begin
    if falling_edge(LRCK_DSDBCK) then
      dataShiftRegisterL <= shift_left(
        to_signed(vInLeft, dataShiftRegisterL'length),
        formatShiftBitNb
      );
      dataShiftRegisterR <= shift_left(
        to_signed(vInRight, dataShiftRegisterR'length),
        formatShiftBitNb
      );
    elsif falling_edge(BCK_delayed) then
      if LRCK_DSDBCK = '0' then
        dataShiftRegisterL <= shift_left(dataShiftRegisterL, 1);
      else
        dataShiftRegisterR <= shift_left(dataShiftRegisterR, 1);
      end if;
    end if;
  end process loadOrShift;

  DATA_DSDR <= dataShiftRegisterL(dataShiftRegisterL'high) when LRCK_DSDBCK = '0'
    else dataShiftRegisterR(dataShiftRegisterR'high);

END ARCHITECTURE sim;