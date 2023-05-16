ARCHITECTURE RTL OF udpAppWrite IS

  signal selectedInstance: std_ulogic_vector(txSelectedInstance'range);

  signal timeoutCounter: unsigned(timeoutCounterBitNb-1 downto 0);

  type selectStateType is (
    idle, checkRequests, waitTransmission, turnover
  );
  signal selectState: selectStateType;

BEGIN
  ------------------------------------------------------------------------------
                                                                -- selection FSM
  selectionSequencer: process(reset, clock)
  begin
    if reset = '1' then
      selectState <= idle;
    elsif rising_edge(clock) then
      case selectState is
        when idle =>
          if unsigned(writeRequest) /= 0 then
            selectState <= checkRequests;
          end if;
        when checkRequests =>
          selectState <= waitTransmission;
        when waitTransmission =>
          if unsigned(writeRequest and selectedInstance) = 0 then
            selectState <= turnover;
          end if;
        when turnover =>
          if signed(timeoutCounter) = -1 then
            if unsigned(writeRequest) = 0 then
              selectState <= idle;
            else
              selectState <= checkRequests;
            end if;
          end if;
      end case;
    end if;
  end process selectionSequencer;

  ------------------------------------------------------------------------------
                                                          -- selection algorithm
  selectComponent: process(reset, clock)
    variable instanceIndex : natural range 0 to selectedInstance'length;
  begin
    if reset = '1' then
      selectedInstance <= (others => '0');
    elsif rising_edge(clock) then
      if selectState = checkRequests then
        selectedInstance <= (others => '0');
        instanceIndex := 0;
        for index in writeRequest'range loop
          if writeRequest(index) = '1' then
            instanceIndex := index;
          end if;
        end loop;
        if instanceIndex > 0 then
          selectedInstance(instanceIndex) <= '1';
        end if;
      end if;
    end if;
  end process selectComponent;

  txSelectedInstance <= selectedInstance;

  ------------------------------------------------------------------------------
                                         -- timeout counter between 2 selections
  countTimeout: process(reset, clock)
  begin
    if reset = '1' then
      timeoutCounter <= (others => '0');
    elsif rising_edge(clock) then
      if selectState = waitTransmission then
        timeoutCounter <= (others => '0');
      elsif selectState = turnover then
        timeoutCounter <= timeoutCounter + 1;
      end if;
    end if;
  end process countTimeout;

END ARCHITECTURE RTL;
