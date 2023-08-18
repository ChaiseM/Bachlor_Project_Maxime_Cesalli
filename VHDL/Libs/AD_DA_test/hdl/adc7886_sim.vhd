library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc7886 IS
                                                                      -- timings
  constant th1 : time := 5.5 ns;  -- hold time : SCLK falling to data valid

                                                                -- pluse counter
  constant clockPulsesPerSample : positive := 16;
  signal clockPulsesCounter : natural;
                                                        -- sampling and shifting
  signal dataShiftRegister: unsigned(clockPulsesPerSample-1 downto 0);
                                                                        -- state
  signal powered: boolean := true;

BEGIN

  ------------------------------------------------------------------------------
                                                                -- pluse counter
  countPulses: process(CS_n, SCLK)
  begin
    if CS_n = '1' then
      clockPulsesCounter <= 0;
    elsif rising_edge(SCLK) then
      clockPulsesCounter <= clockPulsesCounter + 1;
    end if;
  end process countPulses;

  ------------------------------------------------------------------------------
                                                        -- sampling and shifting
  sampleAndShift: process(CS_n, SCLK)
  begin
    if falling_edge(CS_n) then
      dataShiftRegister <= to_unsigned(VIN, dataShiftRegister'length);
    elsif rising_edge(CS_n) then
      dataShiftRegister <= (others => 'Z');
    elsif falling_edge(SCLK) then
      dataShiftRegister <= shift_left(dataShiftRegister, 1);
      dataShiftRegister(0) <= 'Z';
    end if;
  end process sampleAndShift;

  SDO <= dataShiftRegister(dataShiftRegister'high) after th1 when powered
    else 'Z';

  ------------------------------------------------------------------------------
                                                                        -- state
  updateState: process(CS_n)
  begin
    if rising_edge(CS_n) then
      if (clockPulsesCounter > 2) and (clockPulsesCounter < 10) then
        powered <= false;
      elsif clockPulsesCounter > 10 then
        powered <= true;
      end if;
    end if;
  end process updateState;

END ARCHITECTURE sim;
