ARCHITECTURE RTL OF frequencyRegulator IS

  constant outputOffset: unsigned(controlAmplitude'range)
    := shift_left(resize("01", controlAmplitude'length), controlAmplitude'length-1)-10;

  constant proportionalBitNb: positive := controlAmplitude'length;
  signal proportionalShifted: signed(periodDiff'length+proportionalShift-1 downto 0);
  signal proportionalOverflow: std_ulogic;
  signal proportional: signed(proportionalBitNb-1 downto 0);
  constant integralBitNb: positive := periodDiff'length+integralShift+4;
  signal integralShifted: signed(periodDiff'length+integralShift-1 downto 0);
  signal integralOverflow: std_ulogic;
  signal integralUnderflow: std_ulogic;
  signal integralSum, integral: signed(integralBitNb-1 downto 0);
  signal sum: signed(controlAmplitude'length+2-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                            -- proportional term
  propGreaterEqual1: if proportionalShift >= 0 generate
    proportionalShifted <= shift_left(
      resize(periodDiff, proportionalShifted'length),
      proportionalShift
    );
  end generate propGreaterEqual1;

  propSmaller1: if proportionalShift < 0 generate
    proportionalShifted <= shift_right(
      resize(periodDiff, proportionalShifted'length),
      -proportionalShift
    );
  end generate propSmaller1;

  proportionalOverflow <= '0' when shift_right(proportionalShifted, periodDiff'length) = 0
    else '0' when shift_right(proportionalShifted, periodDiff'length)+1 = 0
    else '1';

  limitOverflow: process(proportionalOverflow, proportionalShifted)
  begin
    if proportionalOverflow = '0' then
      proportional <= resize(
        shift_right(
          proportionalShifted,
          periodDiff'length - proportional'length
        ),
        proportional'length
      );
    else
      proportional <= (others => not proportionalShifted(proportionalShifted'high));
      proportional(proportional'high) <= proportionalShifted(proportionalShifted'high);
    end if;
  end process limitOverflow;

  ------------------------------------------------------------------------------
                                                                -- integral term
  integralGreaterEqual1: if integralShift >= 0 generate
    integralShifted <= shift_left(
      resize(periodDiff, integralShifted'length),
      integralShift
    );
  end generate integralGreaterEqual1;

  integralSmaller1: if integralShift < 0 generate
    integralShifted <= shift_right(
      resize(periodDiff, integralShifted'length),
      -integralShift
    );
  end generate integralSmaller1;

  integralSum <= integral + integralShifted;

  integralOverflow <= '0' when integralSum < 0
    else '0' when shift_right(integralSum, periodDiff'length) = 0
    else '1';

  integralUnderflow <= '0' when integralSum >= 0
    else '0' when shift_right(integralSum, periodDiff'length)+1 = 0
    else '1';

  accumulate: process(reset, clock)
  begin
    if reset = '1' then
      integral <= (others => '0');
    elsif rising_edge(clock) then
      if en = '1' then
        if (integralOverflow = '0') and (integralUnderflow = '0') then
          integral <= integralSum;
        end if;
      end if;
    end if;
  end process;

--  accumulate: process(reset, clock)
--  begin
--    if reset = '1' then
--      integral <= (others => '0');
--    elsif rising_edge(clock) then
--      if en = '1' then
--        if periodDiff > 0 then
--          integral <= integral + 1;
--        elsif periodDiff < 0 then
--          integral <= integral - 1;
--        end if;
--      end if;
--    end if;
--  end process;

  ------------------------------------------------------------------------------
                                                             -- regulator output
  sum <= signed(resize(outputOffset, sum'length)) +
    proportional + 
    resize(integral, sum'length);

  controlAmplitude <= to_unsigned(10, controlAmplitude'length) when sum < 0
    else (others => '1') when shift_right(sum, controlAmplitude'length) > 0
    else resize(unsigned(sum), controlAmplitude'length);

END ARCHITECTURE RTL;
