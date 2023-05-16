ARCHITECTURE masterVersion OF risingDetector IS

  signal sigInDelayed: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                                  -- delay input
  delayInput: process(reset, clock)
  begin
    if reset = '1' then
      sigInDelayed <= '0';
    elsif rising_edge(clock) then
      sigInDelayed <= sigIn;
    end if;
  end process delayInput;

  ------------------------------------------------------------------------------
                                                                  -- find change
  rising <= '1' when (sigIn = '1') and (sigInDelayed = '0')
    else '0';

END ARCHITECTURE masterVersion;
