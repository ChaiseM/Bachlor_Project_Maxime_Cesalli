ARCHITECTURE RTL OF nonOverlap IS

  signal pwmDelayed, pwmChanged : std_ulogic;
  signal deadTimeCounter : unsigned(counterBitNb-1 downto 0);
  signal isDeadTime : std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                        -- detect changes on PWM
  delayPwm: process(clock, reset)
  begin
    if reset = '1' then
      pwmDelayed <= '0';
    elsif rising_edge(clock) then
      pwmDelayed <= pwmIn;
    end if;
  end process delayPwm;

  pwmChanged <= '1' when pwmDelayed /= pwmIn
    else '0';

  ------------------------------------------------------------------------------
                                                              -- count dead time
  countDeadTime: process(clock, reset)
  begin
    if reset = '1' then
      deadTimeCounter <= (others => '0');
    elsif rising_edge(clock) then
      if deadTimeCounter > 0 then
        deadTimeCounter <= deadTimeCounter + 1;
      elsif pwmChanged = '1' then
        deadTimeCounter <= deadTimeCounter + 1;
      end if;
    end if;
  end process countDeadTime;

  ------------------------------------------------------------------------------
                                 -- build complementary non overlapping controls
  isDeadTime <= '1' when (deadTimeCounter > 0) or (pwmChanged = '1')
    else '0';

  buildComplementaryControls: process(clock, reset)
  begin
    if reset = '1' then
      pwmOut <= '0';
      pwmOut_n <= '0';
    elsif rising_edge(clock) then
                                                               -- direct control
      if (pwmIn = '1') and (isDeadTime = '0') then
        pwmOut <= '1';
      else
        pwmOut <= '0';
      end if;
                                                             -- inverted control
      if (pwmIn = '0') and (isDeadTime = '0') then
        pwmOut_n <= '1';
      else
        pwmOut_n <= '0';
      end if;
    end if;
  end process buildComplementaryControls;

END ARCHITECTURE RTL;
