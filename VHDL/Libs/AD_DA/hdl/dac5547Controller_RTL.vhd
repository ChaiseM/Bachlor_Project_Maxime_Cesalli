library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF dac5547Controller IS

  signal enableCounter: unsigned(requiredBitNb(delayDivide)-1 downto 0);
  signal timingsEnable: std_ulogic;

  signal resetShiftReg: std_ulogic_vector(1 downto 0);
  signal writeShiftReg: std_ulogic_vector(5 downto 0);

BEGIN

  ------------------------------------------------------------------------------
                                                           -- enable for timings
  generateEnPulses: process(reset, clock)
  begin
    if reset = '1' then
      enableCounter <= (others => '0');
    elsif rising_edge(clock) then
      if timingsEnable = '1' then
        enableCounter <= (others => '0');
      else
        enableCounter <= enableCounter + 1;
      end if;
    end if;
  end process generateEnPulses;

  timingsEnable <= '1' when enableCounter = delayDivide-1
    else '0';

  ------------------------------------------------------------------------------
                                                                -- configuration
  MSB <= not resetLow;

  ------------------------------------------------------------------------------
                                                               -- power-on reset
  buildPowerOnReset: process(reset, clock)
  begin
    if reset = '1' then
      resetShiftReg <= (others => '0');
    elsif rising_edge(clock) then
      if timingsEnable = '1' then
        resetShiftReg(0) <= '1';
        resetShiftReg(resetShiftReg'high downto 1) <=
          resetShiftReg(resetShiftReg'high-1 downto 0);
      end if;
    end if;
  end process buildPowerOnReset;

  RS_n <= not '1' when resetShiftReg(resetShiftReg'high) = '0'
    else not '0';

  ------------------------------------------------------------------------------
                                                                 -- write timing
  buildWriteSignals: process(reset, clock)
  begin
    if reset = '1' then
      writeShiftReg <= (others => '0');
    elsif rising_edge(clock) then
      if newSample = '1' then
        writeShiftReg(0) <= '1';
      elsif timingsEnable = '1' then
        writeShiftReg(0) <= '0';
        writeShiftReg(writeShiftReg'high downto 1) <=
          writeShiftReg(writeShiftReg'high-1 downto 0);
      end if;
    end if;
  end process buildWriteSignals;

  selectAddress: process(reset, clock)
  begin
    if reset = '1' then
      A <= (others => '0');
    elsif rising_edge(clock) then
      if writeShiftReg(writeShiftReg'high) = '1' then
        A <= "00";
      end if;
      if writeShiftReg(2) = '1' then
        A <= "11";
      end if;
    end if;
  end process selectAddress;

  D <= amplitude1 when writeShiftReg(1) = '1'
    else amplitude2 when writeShiftReg(3) = '1'
    else (others => '-');
  WR_n <= not( writeShiftReg(1) or writeShiftReg(3) );
  LDAC <= writeShiftReg(writeShiftReg'high);

END ARCHITECTURE RTL;
