library ieee;
  use ieee.math_real.all;

ARCHITECTURE test OF atan2Pipelined_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';

  signal phase_int: unsigned(phase'range) := (others => '0');
  signal phase_real: real := 0.0;

BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clocks
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                           -- build linear phase
  countPhase: process(clock_int)
  begin
    if rising_edge(clock_int) then
      phase_int <= phase_int + 1;
    end if;
  end process countPhase;
                                                        -- calculate sin and cos
  phase_real <= 2.0*math_pi * real(to_integer(phase_int)) / 2.0**phase_int'length;

  sine <= to_signed(
    integer( sin(phase_real) * (2.0**(sine'length-1) - 1.0) ),
    sine'length
  );

  cosine <= to_signed(
    integer( cos(phase_real) * (2.0**(sine'length-1) - 1.0) ),
    cosine'length
  );

END ARCHITECTURE test;
