ARCHITECTURE masterVersion OF pwmModulator IS

  signal divideCount: unsigned(dividerBitNb-amplitude'length-1 downto 0);
  signal pwmEn: std_ulogic;
  signal amplitudeReg, sawtooth: unsigned(amplitude'range);

BEGIN
  ------------------------------------------------------------------------------
                                                          -- store new amplitude
  storeAmplitude: process(reset, clock)
  begin
    if reset = '1' then
      amplitudeReg <= (others => '0');
    elsif rising_edge(clock) then
      if amplitudeEn = '1' then
        if amplitude(amplitude'high downto amplitude'high-2) /= "111" then
          amplitudeReg <= amplitude;
        end if;
      end if;
    end if;
  end process storeAmplitude;

  ------------------------------------------------------------------------------
                                       -- generate enable pulse for PWM sawtooth
  generatePrescaler: if dividerBitNb > amplitude'length generate

    divideClockFrequency: process(reset, clock)
    begin
      if reset = '1' then
        divideCount <= (others => '0');
      elsif rising_edge(clock) then
        divideCount <= divideCount + 1;
      end if;
    end process divideClockFrequency;

    pwmEn <= '1' when divideCount = 0
      else '0';

  end generate generatePrescaler;
                                                -- no prescaler if not necessary

  alwaysEnable: if dividerBitNb <= amplitude'length generate
    pwmEn <= '1';
  end generate alwaysEnable;

  ------------------------------------------------------------------------------
                                             -- PWM with sawtooth and comparator
  buildSawtooth: process(reset, clock)
  begin
    if reset = '1' then
      sawtooth <= (others => '0');
    elsif rising_edge(clock) then
      if pwmEn = '1' then
        sawtooth <= sawtooth + 1;
      end if;
    end if;
  end process buildSawtooth;

  pwm <= '1' when amplitudeReg > sawtooth
    else '0';

END ARCHITECTURE masterVersion;
