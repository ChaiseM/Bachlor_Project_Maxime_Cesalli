library ieee;
  use ieee.math_real.all;
library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF atan2Pipelined IS

  constant iterationNb: positive := signalBitNb+2;

  subtype registerType is signed(signalBitNb-1+1 downto 0);
  type    registerArrayType is array (1 to iterationNb) of registerType;

  subtype phaseType is signed(phaseBitNb-1 downto 0);
  type phaseArrayType is array (1 to iterationNb) of phaseType;
  type clockWiseArrayType is array(1 to iterationNb) of std_ulogic;

  function initPhaseArray return phaseArrayType is
    variable phaseIncrement: phaseArrayType;
  begin
    for index in 1 to phaseIncrement'length loop
      phaseIncrement(index) := to_signed(integer( arctan(1.0/2.0**(index-1)) / math_pi * 2.0**(phaseBitNb-1) ), phaseBitNb);
    end loop;
    return phaseIncrement;
  end initPhaseArray;

  constant angle180    : phaseType := (phaseType'high => '1', others => '0');
  constant phaseIncrement: phaseArrayType := initPhaseArray;

  signal registerX     : registerArrayType;
  signal registerY     : registerArrayType;
  signal signX         : std_ulogic_vector(iterationNb downto 0);
  signal angle         : phaseArrayType;
  signal clockWise     : clockWiseArrayType;

BEGIN

  -- Fill the registers
  vectorize: process(reset, clock)
  begin
    if reset = '1' then
      registerX <= (others => (others => '0'));
      registery <= (others => (others => '0'));
      angle <= (others => (others => '0'));
      signX <= (others => '0');
    elsif rising_edge(clock) then
      -- Check if the vector is on the left part of a circle (X msb value = '1')
      if cosine(cosine'high) = '0' then
        registerX(1) <= resize(cosine, registerX(1)'length);
      else
        registerX(1) <= resize(-cosine, registerX(1)'length);
      end if;
      registerY(1) <= resize(sine, registerX(1)'length);
      signX(1) <= cosine(signalBitNb - 1);
      
      for index in 1 to iterationNb-1 loop
        if clockWise(index) = '1' then
          registerX(index+1) <= registerX(index) - shift_right(registerY(index), index-1);
          registerY(index+1) <= registerY(index) + shift_right(registerX(index), index-1);
          angle(index+1) <= angle(index) - phaseIncrement(index);
        else
          registerX(index+1) <= registerX(index) + shift_right(registerY(index), index-1);
          registerY(index+1) <= registerY(index) - shift_right(registerX(index), index-1);
          angle(index+1) <= angle(index) + phaseIncrement(index);
        end if;
        signX(index + 1) <= signX(index);
      end loop;
      
    end if;
  end process vectorize;

  -- Set the clockWise of rotation for each value
  dir: process(registerY)
  begin
    for index in 1 to iterationNb loop
      if registerY(index) < 0 then
        clockWise(index) <= '1';
      else
        clockWise(index) <= '0';
      end if;
    end loop;
  end process dir;
  
  -- Set the output
  output: process(angle, signX)
  begin
    if signX(signX'high) = '0' then
      phase <= resize(unsigned(angle(angle'high)), phaseBitNb);
    else
      phase <= resize(unsigned(angle180 - angle(angle'high)), phaseBitNb);
    end if;
  end process output;
END RTL;
