ARCHITECTURE RTL OF synchLogicPulse IS

  signal dataDiv2: std_ulogic;
  signal dataDiv2Synch: std_ulogic;
  signal dataDiv2SynchDelayed: std_ulogic;

BEGIN

  divideBy2: process(reset, clock)
  begin
    if reset = '1' then
      dataDiv2 <= '0';
    elsif rising_edge(clock) then
      if dataIn = '1' then
        dataDiv2 <= not dataDiv2;
      end if;
    end if;
  end process divideBy2;

  synchData: process(resetSynch, clockSynch)
  begin
    if resetSynch = '1' then
      dataDiv2Synch <= '0';
    elsif rising_edge(clockSynch) then
      dataDiv2Synch <= dataDiv2;
    end if;
  end process synchData;

  delayData: process(resetSynch, clockSynch)
  begin
    if resetSynch = '1' then
      dataDiv2SynchDelayed <= '0';
    elsif rising_edge(clockSynch) then
      dataDiv2SynchDelayed <= dataDiv2Synch;
    end if;
  end process delayData;

  dataSynch <= '1' when dataDiv2SynchDelayed /= dataDiv2Synch
    else '0';

END ARCHITECTURE RTL;
