--------------------------------------------------------------------------------
-- Copyright 2013 HES-SO Valais Wallis (www.hevs.ch)
--------------------------------------------------------------------------------
-- SPI master interface
--   More information: http://wiki.hevs.ch/uit/index.php5/Components/IP/SPI  
--
--   Created on 2021-02-16
--
--   Version: 1.0
--   Author: François Corthay (francois.corthay@hevs.ch)
--------------------------------------------------------------------------------

LIBRARY Common;
USE Common.CommonLib.all;

architecture RTL of spiTransceiver_slave is
                                                             -- sClk active edge
  signal sClk_int, sClk_delayed, sClk_en : std_uLogic;
                                                        -- start and end of word
  signal slaveSel_delayed, startOfWord, endOfWord : std_uLogic;
                                                              -- shift registers
  signal inputShiftRegister : std_ulogic_vector(dataOut'range); 
  signal outputShiftRegister : std_ulogic_vector(dataIn'range);

begin
  ------------------------------------------------------------------------------
                                                        -- find sClk active edge
  sClk_int <= sClk xor cPol;

  delaySClk: process(reset, clock)
  begin
    if reset = '1' then
      sClk_delayed <= cPol;
    elsif rising_edge(clock) then
      sClk_delayed <= sClk_int;
    end if;
  end process delaySClk;

  findClkEdge: process(sClk_int, sClk_delayed)
  begin
    sClk_en <= '0';
    if cPha = '0' then
      if (sClk_int = '1') and (sClk_delayed = '0') then
        sClk_en <= '1';
      end if;
    else
      if (sClk_int = '0') and (sClk_delayed = '1') then
        sClk_en <= '1';
      end if;
    end if;
  end process findClkEdge;

  ------------------------------------------------------------------------------
                                                   -- find start and end of word
  delaySlaveSel: process(reset, clock)
  begin
    if reset = '1' then
      slaveSel_delayed <= '0';
    elsif rising_edge(clock) then
      slaveSel_delayed <= slaveSel;
    end if;
  end process delaySlaveSel;

  startOfWord <= '1' when (slaveSel = '1') and (slaveSel_delayed = '0')
    else '0';
  endOfWord <= '1' when (slaveSel = '0') and (slaveSel_delayed = '1')
    else '0';

  ------------------------------------------------------------------------------
                                                              -- shift registers
  shiftMosiData: process(reset, clock)
  begin
    if reset = '1' then
      inputShiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      if sClk_en = '1' then
        inputShiftRegister(inputShiftRegister'high downto 1) <=
          inputShiftRegister(inputShiftRegister'high-1 downto 0);
        inputShiftRegister(0) <= MOSI;
      end if;
    end if;
  end process shiftMosiData;

  shiftMisoData: process(reset, clock)
  begin
    if reset = '1' then
      outputShiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      if startOfWord = '1' then
        outputShiftRegister <= dataIn;
      elsif sClk_en = '1' then
        outputShiftRegister(outputShiftRegister'high downto 1) <=
          outputShiftRegister(outputShiftRegister'high-1 downto 0);
        outputShiftRegister(0) <= '0';
      end if;
    end if;
  end process shiftMisoData;

  MISO <= outputShiftRegister(outputShiftRegister'high);

  ------------------------------------------------------------------------------
                                                                      -- outputs
  storeOutputs: process(reset, clock)
  begin
    if reset = '1' then
      dataOut <= (others => '0');
      dataValid <= '0';
    elsif rising_edge(clock) then
      dataValid <= '0';
      if endOfWord = '1' then
        dataOut <= inputShiftRegister;
        dataValid <= '1';
      end if;
    end if;
  end process storeOutputs;

end RTL;
