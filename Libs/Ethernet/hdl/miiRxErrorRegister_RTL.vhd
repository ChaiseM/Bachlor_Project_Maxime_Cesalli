ARCHITECTURE RTL OF miiRxErrorRegister IS

  signal errorCode_int : std_ulogic_vector(errorCode'range);

BEGIN


  shiftData: process(reset, clock)
  begin
    if reset = '1' then
      errorCode_int <= (others => '0');
    elsif rising_edge(clock) then
      if loadError = '1' then
        errorCode_int <= errorCode_int or loadCode;
      elsif clearErrors = '1' then
        errorCode_int <= (others => '0');
      end if;
    end if;
  end process shiftData;

  errorCode <= errorCode_int;

END ARCHITECTURE RTL;
