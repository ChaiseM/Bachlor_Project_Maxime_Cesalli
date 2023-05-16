library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF ethernetPack IS

  constant dataShift: natural := requiredBitNb(tx_data'length/ethData'length)-1;
  constant minFrameLength: positive := 60 * 8 / tx_data'length;
  constant ethOffset: positive := 1 + (
    sourceMacAddr'length + destMacAddr'length + etherType'length
  ) / tx_data'length;

  type packStateType is (
    init, idle,
    writeDestAddr, writeSourceAddr, writeEtherType,
    transparent, pad,
    endOfFrame, writeLength
  );
  signal packState: packStateType;

  signal baseAddress: unsigned(tx_address'range);
  signal txAddress_int: unsigned(tx_address'range);
  signal addressCounter: unsigned(tx_address'range);
  signal ethAddressShifted: unsigned(tx_address'range);
  signal dataStored: std_ulogic_vector(ethData'range);
  signal dataPacked: std_ulogic_vector(tx_data'range);
  signal dataShiftRegister: unsigned(sourceMacAddr'range);
  signal frameLengthRam: unsigned(tx_address'range);
  signal frameLengthBytes: unsigned(tx_data'range);

BEGIN

  ethAddressShifted <= shift_right(ethAddress, dataShift) + ethOffset;

  ------------------------------------------------------------------------------
                                                                    -- sequencer
  packFsm: process(reset, clock)
  begin
    if reset = '1' then
      packState <= init;
    elsif rising_edge(clock) then
      case packState is
        when init =>
          packState <= idle;
        when idle =>
          if sendFrame = '1' then
            packState <= writeDestAddr;
          end if;
        when writeDestAddr =>
          if addressCounter = 3 then
            packState <= writeSourceAddr;
          end if;
        when writeSourceAddr =>
          if addressCounter >= 6 then
            packState <= writeEtherType;
          end if;
        when writeEtherType =>
          if addressCounter >= 7 then
            packState <= transparent;
          end if;
        when transparent =>
          if sendFrame = '0' then
            if frameLengthRam > minFrameLength-2 then
              packState <= endOfFrame;
            else
              packState <= pad;
            end if;
          end if;
        when pad =>
          if frameLengthRam > minFrameLength-2 then
            packState <= endOfFrame;
          end if;
        when endOfFrame =>
          packState <= writeLength;
        when writeLength =>
          packState <= idle;
      end case;
    end if;
  end process packFsm;

  packControls: process(
    packState,
    baseAddress, addressCounter, ethAddress, frameLengthRam, frameLengthBytes,
    dataShiftRegister, dataPacked,
    ethAddressShifted, ethWrite
  )
  begin
    tx_address <= (others => '0');
    tx_data <= (others => '0');
    tx_write <= '0';
    ready <= '0';
    case packState is
      when init =>
        tx_write <= '1';
      when writeDestAddr =>
        tx_address <= baseAddress + addressCounter;
        tx_data <= std_ulogic_vector(
          dataShiftRegister(
            destMacAddr'high downto destMacAddr'high-tx_data'length+1
          )
        );
        tx_write <= '1';
      when writeSourceAddr =>
        tx_address <= baseAddress + addressCounter;
        tx_data <= std_ulogic_vector(
          dataShiftRegister(
            sourceMacAddr'high downto sourceMacAddr'high-tx_data'length+1
          )
        );
        tx_write <= '1';
      when writeEtherType =>
        tx_address <= baseAddress + addressCounter;
        tx_data <= std_ulogic_vector(
          dataShiftRegister(
            etherType'high downto etherType'high-tx_data'length+1
          )
        );
        tx_write <= '1';
      when transparent =>
        tx_address <= baseAddress + ethAddressShifted;
        if ethAddress(0) = '1' then
          tx_data <= dataPacked;
        else
          tx_data <= std_ulogic_vector(
            shift_left(unsigned(dataPacked), ethData'length)
          );
        end if;
        ready <= '1';
        tx_write <= ethWrite;
      when endOfFrame =>
        tx_address <= baseAddress + frameLengthRam + 1;
        tx_write <= '1';
      when pad =>
        tx_address <= baseAddress + frameLengthRam + 1;
        tx_write <= '1';
      when writeLength =>
        tx_address <= baseAddress;
        tx_data <= std_ulogic_vector(
          resize(
            frameLengthBytes + ethOffset*2**dataShift,
            tx_data'length
          )
        );
        tx_data(tx_data'high) <= '1';
        tx_write <= '1';
      when others => null;
    end case;
  end process packControls;

  ------------------------------------------------------------------------------
                                                         -- frame length counter
  calculateFrameLength: process(reset, clock)
  begin
    if reset = '1' then
      frameLengthRam <= (others => '0');
      frameLengthBytes <= (others => '0');
    elsif rising_edge(clock) then
      if packState = idle then
        frameLengthRam <= (others => '0');
        frameLengthBytes <= (others => '0');
      elsif (packState = transparent) and (sendFrame = '1')
      and (ethWrite = '1') then
        if ethAddressShifted > frameLengthRam then
          frameLengthRam <= ethAddressShifted;
        end if;
        if ethAddress > frameLengthBytes then
          frameLengthBytes <= resize(ethAddress,frameLengthBytes'length);
        end if;
      elsif packState = pad then
        frameLengthRam <= frameLengthRam + 1;
        frameLengthBytes <= frameLengthBytes + 2;
      end if;
    end if;
  end process calculateFrameLength;

  ------------------------------------------------------------------------------
                                                        -- base address register
  storeBaseAddress: process(reset, clock)
  begin
    if reset = '1' then
      baseAddress <= (others => '0');
    elsif rising_edge(clock) then
      if packState = writeLength then
        baseAddress <= baseAddress + frameLengthRam + 1;
      end if;
   end if;
  end process storeBaseAddress;

  ------------------------------------------------------------------------------
                                                              -- address counter
  incrementAddress: process(reset, clock)
  begin
    if reset = '1' then
      addressCounter <= (others => '0');
    elsif rising_edge(clock) then
      if packState = idle then
        addressCounter <= to_unsigned(1, addressCounter'length);
      else
        addressCounter <= addressCounter + 1;
      end if;
   end if;
  end process incrementAddress;

  ------------------------------------------------------------------------------
                                              -- build several words out of data
  shiftData: process(reset, clock)
  begin
    if reset = '1' then
      dataShiftRegister <= (others => '0');
    elsif rising_edge(clock) then
      if packState = idle then
        dataShiftRegister <= unsigned(destMacAddr);
      elsif (packState = writeDestAddr) and (addressCounter = 3) then
        dataShiftRegister <= unsigned(sourceMacAddr);
      elsif (packState = writeSourceAddr) and (addressCounter = 6) then
        dataShiftRegister(etherType'range) <= unsigned(etherType);
      else
        dataShiftRegister <= shift_left(dataShiftRegister, tx_data'length);
      end if;
    end if;
  end process shiftData;

  ------------------------------------------------------------------------------
                                        -- demultiplex data from fifo word width
  storeData: process(reset, clock)
  begin
    if reset = '1' then
      dataStored <= (others => '0');
    elsif rising_edge(clock) then
      dataStored <= ethData;
    end if;
  end process storeData;

  dataPacked <= dataStored & ethData;

END ARCHITECTURE RTL;
