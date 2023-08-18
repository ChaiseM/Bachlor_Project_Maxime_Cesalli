--------------------------------------------------------------------------------
-- Copyright 2016 HES-SO Valais Wallis (www.hevs.ch)
--------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program IS distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License along with
-- this program. If not, see <http://www.gnu.org/licenses/>
-- -----------------------------------------------------------------------------
-- miiRxDataToByte
--
-- -----------------------------------------------------------------------------
--  Authors:
--    cof: [François Corthay](francois.corthay@hevs.ch)
--    guo: [Oliver A. Gubler](oliver.gubler@hevs.ch)
-- -----------------------------------------------------------------------------
-- Changelog:
--   2016-03-31 : guo : modif to reduce logic on readAddress calculation
--   2016-03-30 : cof : add error checks
--   2016-03-23 : guo : modif to prevent Vivado synthesize error
--   2016-03-17 : cof : compatible with read pauses
--   2016-03-15 : cof : added byte counter
--   2016-03-01 : cof : functional version
--   2016-03-01 : cof : first raw release
-- -----------------------------------------------------------------------------

library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF ethernetFifoRx IS
                                                                -- MII interface
  type miiStateType is (
    idle, readLength, readFrame, updateBaseAddress, skipError
  );
  signal miiState: miiStateType;

  -- ramDataBitNb must be multiple of fifoDataBitNb
  constant fifoPerRamWords: positive := ramDataBitNb/fifoDataBitNb;
  constant RamToFifoShift: positive := requiredBitNb(fifoPerRamWords-1);
  signal byteCounter, readFrameLength: unsigned(rx_address'high+RamToFifoShift downto 0);
  signal byteEnable: unsigned(RamToFifoShift-1 downto 0);
  signal readAddress, readBaseAddress, readBaseAddressPlusOne: unsigned(rx_address'range);
  constant errorFlagsNb: positive := 3;
  signal errorCode: unsigned(errorFlagsNb-1 downto 0);
                                                               -- FIFO interface
  type fifoStateType is (
    idle, readFrame, readWait
  );
  signal fifoState: fifoStateType;
  signal fifoData, fifoDataSampled: std_ulogic_vector(rx_fifoData'range);

BEGIN
  --============================================================================
  -- MII interface
  --
  -- beware: the frame RAM provides read data one clock period after the address
  -- has been provided.
                                                                   -- error code
  errorCode <= resize(
    shift_right(
      unsigned(rx_data),
      rx_data'length - 1 - errorCode'length
    ),
    errorCode'length
  );
                                                                   -- Rx control
  rxMiiFsm: process(reset, clock)
  begin
    if reset = '1' then
      miiState <= idle;
    elsif rising_edge(clock) then
      case miiState is
        when idle =>
          if rx_data(rx_data'high) = '1' then
            if errorCode = 0 then
              miiState <= readLength;
            else
              miiState <= skipError;
            end if;
          end if;
        when readLength => 
          miiState <= readFrame;
        when readFrame =>
          if byteCounter = readFrameLength-1 then
            miiState <= updateBaseAddress;
          end if;
        when updateBaseAddress =>
          miiState <= idle;
        when skipError => 
          miiState <= idle;
      end case;
    end if;
  end process rxMiiFsm;
                                                              -- Rx frame length
  updateReadFrameLength: process(reset, clock)
  begin
    if reset = '1' then
      readFrameLength <= (others => '0');
    elsif rising_edge(clock) then
      if miiState = readLength then
        readFrameLength <= resize(unsigned(rx_data), readFrameLength'length);
      end if;
    end if;
  end process updateReadFrameLength;
                                                              -- Rx byte counter
  updateByteCounter: process(reset, clock)
  begin
    if reset = '1' then
      byteCounter <= (others => '0');
    elsif rising_edge(clock) then
      if miiState = idle then
        byteCounter <= (others => '0');
      elsif miiState = readlength then
        byteCounter <= byteCounter + 1;
      elsif miiState = readFrame then
        if rx_fifoRead = '1' then
          byteCounter <= byteCounter + 1;
        end if;
      elsif miiState = updateBaseAddress then
        byteCounter <= byteCounter + 1;
      end if;
    end if;
  end process updateByteCounter;
                                                           -- Rx address counter
  readAddress <= readBaseAddress when miiState = idle
    else resize(
      shift_right(byteCounter, RamToFifoShift),
      readAddress'length
    ) + readBaseAddressPlusOne;

  rx_address <= readAddress;
                                                              -- Rx base address
  updateReadBaseAddress: process(reset, clock)
  begin
    if reset = '1' then
      readBaseAddress <= (others => '0');
      readBaseAddressPlusOne <= to_unsigned(1, readBaseAddressPlusOne'length);
    elsif rising_edge(clock) then
      if miiState = updateBaseAddress then
        if byteCounter(RamToFifoShift-1 downto 0) = 0 then
          readBaseAddress <= readAddress;
          readBaseAddressPlusOne <= readAddress+1;
        else
          readBaseAddress <= readAddress + 1;
          readBaseAddressPlusOne <= readAddress + 1+1;
        end if;
      elsif miiState = skipError then
        readBaseAddress <= readBaseAddress + 1;
        readBaseAddressPlusOne <= readBaseAddressPlusOne +1;
      end if;
    end if;
  end process updateReadBaseAddress;

  rx_baseAddress <= readBaseAddress;

  --============================================================================
  -- FIFO interface
                                                                   -- Rx control
  rxFifoFsm: process(reset, clock)
  begin
    if reset = '1' then
      fifoState <= idle;
    elsif rising_edge(clock) then
      case fifoState is
        when idle =>
          if miiState = readLength then
            fifoState <= readFrame;
          end if;
        when readFrame =>
          if rx_fifoRead = '0' then
            fifoState <= readWait;
          elsif miiState = updateBaseAddress then
            fifoState <= idle;
          end if;
        when readWait =>
          if rx_fifoRead = '1' then
            fifoState <= readFrame;
          end if;
      end case;
    end if;
  end process rxFifoFsm;

  rx_fifoEmpty <= '0' when (fifoState = readFrame) or (fifoState = readWait)
    else '1';

  byteEnable <= byteCounter(byteEnable'range);

  selectRxByte:
    fifoData <= std_ulogic_vector(
      resize(
        shift_right(
          unsigned(rx_data),
          to_integer(byteEnable) * fifoDataBitNb
        ),
        fifoData'length
      )
    );

  sampleFifoData: process(reset, clock)
  begin
    if reset = '1' then
      fifoDataSampled <= (others => '0');
    elsif rising_edge(clock) then
      if (fifoState = readFrame) and (rx_fifoRead = '0') then
        fifoDataSampled <= fifoData;
      end if;
    end if;
  end process sampleFifoData;

  rx_fifoData <= fifoData when (fifoState = readFrame)
    else fifoDataSampled;

END ARCHITECTURE RTL;
