ARCHITECTURE masterVersion OF phaseDetector IS

  constant mainsCount: positive := integer(clockFrequency/mainsFrequency+0.5);
  signal refCount, fbCount, refPeriod, fbPeriod: unsigned(periodDifference'range);
  signal noInputRefCount: unsigned(refCount'range);
  signal noInput, noInputRefPhase, refPhaseMux: std_ulogic;
  signal fbPhaseDelayed1, fbPhaseDelayed2: std_ulogic;
  signal fbCountSampled: unsigned(refCount'range);
  signal phaseDiffwrapped, phaseDiffdelayed: signed(fbCountSampled'range);
  signal refPeriodSigned: signed(refPeriod'high+1 downto 0);
  signal unwrapOffset: signed(phaseDifference'range);

BEGIN
  ------------------------------------------------------------------------------
                                                         -- count signal periods
                                      -- count clock periods of reference signal
  countRefPeriod: process(reset, clock)
  begin
    if reset = '1' then
      refCount <= (others => '0');
    elsif rising_edge(clock) then
      if refPhase = '1' then
        refCount <= (others => '0');
      else
        refCount <= refCount + 1;
      end if;
    end if;
  end process countRefPeriod;

  ------------------------------------------------------------------------------
                                      -- simulate reference signal when no input
  countNoInputRefPeriod: process(reset, clock)
  begin
    if reset = '1' then
      noInputRefCount <= (others => '0');
    elsif rising_edge(clock) then
      if noInputRefPhase = '1' then
        noInputRefCount <= (others => '0');
      else
        noInputRefCount <= noInputRefCount + 1;
      end if;
    end if;
  end process countNoInputRefPeriod;

  noInputRefPhase <= '1' when noInputRefCount = mainsCount-1
    else '0';
                                          -- check for reference signal presence
  checkRefPeriod: process(reset, clock)
  begin
    if reset = '1' then
      noInput <= '0';
    elsif rising_edge(clock) then
      if signed(refCount)+1 = 0 then
        noInput <= '1';
      elsif refPhase = '1' then
        if abs(signed(refCount-mainsCount)) < mainsCount/10 then
          noInput <= '0';
        else
          noInput <= '1';
        end if;
      end if;
    end if;
  end process checkRefPeriod;

  refPhaseMux <= noInputRefPhase when noInput = '1'
    else refPhase;
  noRefInput <= noInput;

  ------------------------------------------------------------------------------
                                           -- calculate wrapped phase difference
                                                             -- store ref period
  storeRefPeriod: process(reset, clock)
  begin
    if reset = '1' then
      refPeriod <= (others => '0');
    elsif rising_edge(clock) then
      if refPhase = '1' then
        refPeriod <= refCount + 1;
      elsif (noInput = '1') and (noInputRefPhase = '1') then
        refPeriod <= noInputRefCount + 1;
      end if;
    end if;
  end process storeRefPeriod;
                                                              -- sample fb count
  sampleFbCount: process(reset, clock)
  begin
    if reset = '1' then
      fbCountSampled <= (others => '0');
    elsif rising_edge(clock) then
      if fbPhase = '1' then
        if noInput = '1' then
          fbCountSampled <= noInputRefCount;
        else
          fbCountSampled <= refCount;
        end if;
      end if;
    end if;
  end process sampleFbCount;
                                                  -- choose between lead and lag
  calcPhaseDiff: process(refPeriod, fbCountSampled)
  begin
    if fbCountSampled < refPeriod/2 then
      phaseDiffwrapped <= signed(fbCountSampled);
    else
      phaseDiffwrapped <= signed(fbCountSampled - refPeriod);
    end if;
  end process calcPhaseDiff;

  ------------------------------------------------------------------------------
                                                      -- unwrap phase difference
                                                            -- delay phase pulse
  delayFbPhase: process(reset, clock)
  begin
    if reset = '1' then
      fbPhaseDelayed1 <= '0';
      fbPhaseDelayed2 <= '0';
    elsif rising_edge(clock) then
      fbPhaseDelayed1 <= fbPhase;
      fbPhaseDelayed2 <= fbPhaseDelayed1;
    end if;
  end process delayFbPhase;
                                                       -- delay phase difference
  delayPhaseDifference: process(reset, clock)
  begin
    if reset = '1' then
      phaseDiffdelayed <= (others => '0');
    elsif rising_edge(clock) then
      if fbPhase = '1' then
        phaseDiffdelayed <= phaseDiffwrapped;
      end if;
    end if;
  end process delayPhaseDifference;
                                    -- transform refperiod to signed (add 1 MSB)
  refPeriodSigned <= signed(resize(refPeriod, refPeriodSigned'length));
                                                            -- unwrapping offset
  updateOffset: process(reset, clock)
  begin
    if reset = '1' then
      unwrapOffset <= (others => '0');
    elsif rising_edge(clock) then
      if fbPhaseDelayed1 = '1' then
                                                                -- negative jump
        if phaseDiffwrapped - phaseDiffdelayed < -3*refPeriodSigned/4 then
          unwrapOffset <= unwrapOffset + refPeriodSigned;
        end if;
                                                                -- positive jump
        if phaseDiffwrapped - phaseDiffdelayed > 3*refPeriodSigned/4 then
          unwrapOffset <= unwrapOffset - refPeriodSigned;
        end if;
      end if;
    end if;
  end process updateOffset;
                                                        -- add offset and sample
  addOffset: process(reset, clock)
  begin
    if reset = '1' then
      phaseDifference <= (others => '0');
    elsif rising_edge(clock) then
      if fbPhaseDelayed2 = '1' then
        phaseDifference <= unwrapOffset + phaseDiffwrapped;
      end if;
    end if;
  end process addOffset;
                                               -- assert data valid on ref pulse
  delayDataValid: process(reset, clock)
  begin
    if reset = '1' then
      phaseDataValid <= '0';
    elsif rising_edge(clock) then
      phaseDataValid <= refPhaseMux;
    end if;
  end process delayDataValid;

  ------------------------------------------------------------------------------
                                                  -- calculate period difference
                                          -- count clock periods of phase signal
  countfbPeriod: process(reset, clock)
  begin
    if reset = '1' then
      fbCount <= (others => '0');
    elsif rising_edge(clock) then
      if fbPhase = '1' then
        fbCount <= (others => '0');
      else
        fbCount <= fbCount + 1;
      end if;
    end if;
  end process countfbPeriod;
                                                              -- store fb period
  storeFbPeriod: process(reset, clock)
  begin
    if reset = '1' then
      fbPeriod <= (others => '0');
    elsif rising_edge(clock) then
                                                         -- store when new pulse
      if fbPhase = '1' then
        fbPeriod <= fbCount + 1;
                                                         -- saturate on overflow
      elsif signed(fbCount)+1 = 0 then
        fbPeriod <= fbCount;
      end if;
    end if;
  end process storeFbPeriod;

  periodDifference <= signed(
    resize(fbPeriod, periodDifference'length) -
    resize(refPeriod, periodDifference'length)
  );

END ARCHITECTURE masterVersion;
