ARCHITECTURE test OF sinCosPipelinedAmplitude_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_uLogic := '1';
                                                                        -- phase
  signal phase_int: unsigned(phase'range) := (others => '0');
                                                                    -- amplitude
  constant amplitudeStep: positive := 2**(amplitude'length-6);
  signal amplitude_int: signed(amplitude'range) := to_signed(
    -4*amplitudeStep, amplitude'length
  );

BEGIN
  ------------------------------------------------------------------------------
                                                             -- reset and clocks
  reset <= '1', '0' after 2*clockPeriod;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                        -- phase
  countPhase: process(clock_int)
  begin
    if rising_edge(clock_int) then
      phase_int <= phase_int + 1;
    end if;
  end process countPhase;

  phase <= phase_int;

  ------------------------------------------------------------------------------
                                                                    -- amplitude
  countAmplitude: process(phase_int)
  begin
    if phase_int = 0 then
      amplitude_int <= amplitude_int + amplitudeStep;
    end if;
  end process countAmplitude;

  amplitude <= amplitude_int;

END ARCHITECTURE test;
