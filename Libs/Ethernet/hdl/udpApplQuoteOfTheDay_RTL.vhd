ARCHITECTURE RTL OF udpApplQuoteOfTheDay IS

  constant quoteOfTheDay : string(1 to 36) :=
    "Use FPGAs instead of microprocessors";

  signal functionSelected: std_ulogic;
  signal writeRequest_int: std_ulogic;
  signal newData, newDataDelayed: std_ulogic;
  signal sendNewQuote: std_ulogic;
  signal quoteCounter: natural range 0 to quoteOfTheDay'length;

BEGIN
 -------------------------------------------------------------------------------
                                                                -- read from UDP
  functionSelected <= '1' when unsigned(udpPortIn) = quoteOfTheDayPortId
    else '0';
  isSelected <= functionSelected;

  readEn <= functionSelected;

 -------------------------------------------------------------------------------
                                                                 -- write to UDP
  requestWriteAccess: process(reset, clock)
  begin
    if reset = '1' then
      writeRequest_int <= '0';
    elsif rising_edge(clock) then
      if writeRequest_int = '0' then
        if (functionSelected = '1') and (udpDataValid = '1') then
          writeRequest_int <= '1';
        end if;
      else
        if quoteCounter = quoteOfTheDay'length then
          writeRequest_int <= '0';
        end if;
      end if;
    end if;
  end process requestWriteAccess;

  writeRequest <= writeRequest_int;

  newData <= udpDataValid;

  delayNewData: process(reset, clock)
  begin
    if reset = '1' then
      newDataDelayed <= '0';
    elsif rising_edge(clock) then
      newDataDelayed <= newData;
    end if;
  end process delayNewData;

  sendNewQuote <= functionSelected when
      (newData = '1') and (newDataDelayed = '0')
    else '0';

  countCharacters: process(reset, clock)
  begin
    if reset = '1' then
      quoteCounter <= 0;
    elsif rising_edge(clock) then
      if quoteCounter = 0 then
        if sendNewQuote = '1' then
          quoteCounter <= quoteCounter + 1;
        end if;
      else
        if (writeGranted = '1') and (txFull = '0') then
          if quoteCounter < quoteOfTheDay'length then
            quoteCounter <= quoteCounter + 1;
          else
            quoteCounter <= 0;
          end if;
        end if;
      end if;
    end if;
  end process countCharacters;

  txData <= std_ulogic_vector(
      to_unsigned(
        character'pos(quoteOfTheDay(quoteCounter)),
        txData'length
      )
    ) when quoteCounter > 0
    else (others => '-');
  txWr <= '1' when (quoteCounter > 0) and (txFull = '0')
    else '0';

  destUdpPort <= sourceUdpPort;
  udpPortOut <= udpPortIn;
  destIpAddress <= sourceIpAddress;
  destMacAddress <= sourceMacAddress;

END ARCHITECTURE RTL;
