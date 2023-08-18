--------------------------------------------------------------------------------
ARCHITECTURE order1Unsigned OF lowpass IS

  signal unsignedIn: unsigned(parallelIn'range);

  signal integrator: unsigned(parallelIn'high+1 downto 0);
  signal quantized: std_ulogic;

BEGIN

  unsignedIn(unsignedIn'high) <= not parallelIn(parallelIn'high);
  unsignedIn(unsignedIn'high-1 downto 0) <=
                               unsigned(parallelIn(parallelIn'high-1 downto 0));

  modulate: process(reset, clock)
  begin
    if reset = '1' then
      integrator <= (others => '0');
    elsif rising_edge(clock) then
      if quantized = '0' then
        integrator <= integrator + unsignedIn;
      else
        integrator <= integrator + unsignedIn - 2**parallelIn'length;
      end if;
    end if;
  end process modulate;

  quantized <= integrator(integrator'high);

  serialOut <= quantized;

END order1Unsigned;

