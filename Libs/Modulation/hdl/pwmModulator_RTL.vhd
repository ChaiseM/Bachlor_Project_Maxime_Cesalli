ARCHITECTURE RTL OF pwmModulator IS

  signal sawtooth : unsigned(parallelIn'range);

BEGIN
  ------------------------------------------------------------------------------
                                                              -- sawtooth signal
  buildSawtooth: process(clock, reset)
  begin
    if reset = '1' then
      sawtooth <= (others => '0');
    elsif rising_edge(clock) then
      sawtooth <= sawtooth + 1;
    end if;
  end process buildSawtooth;

  ------------------------------------------------------------------------------
                                                    -- compare with input signal
  buildPwm: process(sawtooth, parallelIn)
  begin
    if parallelIn > sawtooth then
      serialOut <= '1';
    else
      serialOut <= '0';
    end if;
  end process buildPwm;

END ARCHITECTURE RTL;
