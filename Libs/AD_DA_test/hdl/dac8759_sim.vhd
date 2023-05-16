library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF dac8759 IS

  subtype registerType is signed(dacBitNb-1 downto 0);
  type registerArrayType is array(1 to dacNb) of registerType;
  signal shiftRegisters: registerArrayType;
  signal shiftEnable: std_ulogic_vector(registerArrayType'range);
  signal shiftCounter: natural;

BEGIN
  ------------------------------------------------------------------------------
                                                         -- count shift position
  countBits: process(LRCIN, BCKIN)
  begin
    if rising_edge(LRCIN) or falling_edge(LRCIN) then
      shiftCounter <= 0;
    elsif rising_edge(BCKIN) then
      shiftCounter <= shiftCounter + 1;
    end if;
  end process countBits;

  ------------------------------------------------------------------------------
                                                            -- shift sample bits
  shiftEnable(1) <= LRCIN;
  shiftEnable(2) <= not LRCIN;

  shiftBits: process(BCKIN)
  begin
    for index in shiftRegisters'range loop
      if shiftEnable(index) = '1' then
        if rising_edge(BCKIN) then
          if shiftCounter <= dacBitNb then
            shiftRegisters(index) <= shift_left(shiftRegisters(index), 1);
            shiftRegisters(index)(0) <= DIN;
          end if;
        end if;
      end if;
    end loop;
  end process shiftBits;

  ------------------------------------------------------------------------------
                                                                      -- outputs
  registerOutputs: process(LRCIN)
  begin
    if falling_edge(LRCIN) then
      HPOUTR <= to_integer(shiftRegisters(1));
      HPOUTL <= to_integer(shiftRegisters(2));
    end if;
  end process registerOutputs;

END ARCHITECTURE RTL;
