--------------------------------------------------------------------------------
library ieee;
  use ieee.math_real.all;
library Common;
  use Common.CommonLib.all;

--------------------------------------------------------------------------------
-- TBD: add an additional bit to registerType in order to prevent overflow
-- see cordicPipelined
--

ARCHITECTURE RTL OF sinCosSequential IS

  constant iterationNb: positive := signalBitNb+2;

  subtype registerType is signed(signalBitNb-1 downto 0);
  constant registerXInit: registerType := to_signed(
        integer(0.6071*2.0**(signalBitNb-1)), registerType'length);
  constant registerYInit: registerType := to_signed(0, registerType'length);

  subtype phaseType is signed(phaseBitNb-1 downto 0);
  type phaseArrayType is array (1 to iterationNb) of phaseType;

  function initPhaseArray return phaseArrayType is
    variable phaseIncrement: phaseArrayType;
  begin
    for index in 1 to phaseIncrement'length loop
      phaseIncrement(index) := to_signed(integer( arctan(1.0/2.0**(index-1)) / math_pi * 2.0**(phaseBitNb-1) ), phaseBitNb);
    end loop;
    return phaseIncrement;
  end initPhaseArray;

  constant phaseIncrement: phaseArrayType := initPhaseArray;

  signal registerX: registerType;
  signal registerY: registerType;
  signal angle: phaseType;
  signal direction: std_ulogic;
  signal iterationCounter: unsigned(requiredBitNb(iterationNb)-1 downto 0);
  signal calculating: std_ulogic;

  signal registerXShifted: registerType;
  signal registerYShifted: registerType;

BEGIN

  count: process(reset, clock)
  begin
    if reset = '1' then
      iterationCounter <= (others => '0');
      calculating <= '0';
      done <= '0';
    elsif rising_edge(clock) then
      done <= '0';
      if iterationCounter = 0 then
        if start = '1' then
          iterationCounter <= iterationCounter + 1;
          calculating <= '1';
        end if;
      elsif iterationCounter < iterationNb then
        iterationCounter <= iterationCounter + 1;
      else
        iterationCounter <= (others => '0');
        calculating <= '0';
        done <= '1';
      end if;
    end if;
  end process count;

  registerXShifted <= shift_right(registerX, to_integer(iterationCounter-1));
  registerYShifted <= shift_right(registerY, to_integer(iterationCounter-1));

  rotate: process(reset, clock)
  begin
    if reset = '1' then
      registerX <= (others => '0');
      registery <= (others => '0');
    elsif rising_edge(clock) then
      if start = '1' then
        registerX <= registerXInit;
        registerY <= registerYInit;
      elsif calculating = '1' then
        if direction = '0' then
          registerX <= registerX - registerYShifted;
          registerY <= registerY + registerXShifted;
        else
          registerX <= registerX + registerYShifted;
          registerY <= registerY - registerXShifted;
        end if;
      end if;
    end if;
  end process rotate;

  trackAngle: process(reset, clock)
  begin
    if reset = '1' then
      angle <= (others => '0');
    elsif rising_edge(clock) then
      if start = '1' then
        if ( phase(phase'high) xor phase(phase'high-1) ) = '0' then
          angle <= signed(phase);
        else
          angle(angle'high) <= phase(phase'high);
          angle(angle'high-1 downto 0) <= signed(not phase(phase'high-1 downto 0));
        end if;
      elsif calculating = '1' then
        if direction = '0' then
          angle <= angle - phaseIncrement(to_integer(iterationCounter));
        else
          angle <= angle + phaseIncrement(to_integer(iterationCounter));
        end if;
      end if;
    end if;
  end process trackAngle;

  direction <= angle(angle'high);

  sine <= registerY;
  cosine <= registerX when phase(phase'high) = phase(phase'high-1) else not registerX;

END RTL;
