--------------------------------------------------------------------------------
-- Copyright 2012 HES-SO Valais Wallis (www.hevs.ch)
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
-- miiSender test
--   
-- -----------------------------------------------------------------------------
--  Authors: 
--    cof: [François Corthay](francois.corthay@hevs.ch)
--    guo: [Oliver A. Gubler](oliver.gubler@hevs.ch)
--    zas: [Silvan Zahno]
-- -----------------------------------------------------------------------------
-- Changelog:
--  2016-01-25: guo
--      doubled frame info length 
--  2015-06 : guo
--      update to be compatible with Gigabit Ethernet (miiDataBitNb = 8)
--  2013-08-09 : zas
--      add 'error' commmand
--  2012-08-20 : guo
--      bugfix for pointer error when line contains only spaces
--  2012-06-19 : zas
--      added preComment
-- -----------------------------------------------------------------------------
LIBRARY std;
  USE std.textio.all;
LIBRARY COMMON_TEST;
  USE COMMON_TEST.testUtils.all;

ARCHITECTURE test OF miiSender IS

  constant clockFrequency: real := real(ethClockFrequency);
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal rxClock_int: std_ulogic := '1';

  constant minDelay: time := 1 ns;
  signal endOfFrameData : boolean := false;
  shared variable frameData : line;
  signal frameInfo : string(1 to 128) := (others => ' ');

  constant errorArrivalIndex : natural := 16;
  signal rxer_error : boolean := false;
  signal rxdv_error : boolean := false;

  constant crc32Polynom : std_ulogic_vector(31 downto 0)
    := "0000" & "0100" & "1100" & "0001" & "0001" & "1101" & "1011" & "0111";
  signal customCrc     : std_ulogic_vector(crc32Polynom'range);
  signal sendCustomCrc : boolean := false;

BEGIN
  ------------------------------------------------------------------------------
                                                                        -- clock
  rxClock_int <= not rxClock_int after clockPeriod/2;
  mii_rxclk <= transport rxClock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                         -- interpret frame file
  parseFile: process
    file frameFile : text;
    variable frameLine : line;
    variable preComment : line;
    variable command : line;
    variable delay : time;
    variable readingFrameData : boolean := false;
    variable firstChar : character;
    variable error : line;
  begin
    if verbosity > 0 then
      print("Opening Ethernet frame file " & framesFileSpec);
    end if;

    file_open(frameFile, framesFileSpec, READ_MODE);
    while not endfile(frameFile) loop
      readline (frameFile, frameLine);
      read_first(frameLine, "#", preComment);
      frameLine := preComment;
      trim_line(frameLine);
      if frameLine.all'length > 0 then
        lc(frameLine);
        if verbosity > 1 then
          print(frameLine.all);
        end if;
        read_first(frameLine, command);
        firstChar := command.all(command.all'left);
        if verbosity > 1 then
          print(command.all & ":" & frameLine.all);
        end if;

        if command.all = "info" then
          rxer_error <= false;
          rxdv_error <= false;
          if verbosity > 0 then
            print("Info: " & frameLine.all);
          end if;
          if frameLine.all'length < frameInfo'length then
            frameInfo <= (others => ' ');
            frameInfo(1 to frameLine.all'length) <= frameLine.all;
          else
            frameInfo <= frameLine.all(1 to frameInfo'length);
          end if;

        elsif command.all = "error" then
          endOfFrameData <= readingFrameData, false after minDelay;
          error := (frameLine);
          if error.all = "rx_err" then
            rxer_error <= true;
          elsif error.all = "rx_dv" then
            rxdv_error <= true;
          end if;

        elsif command.all = "at" then
          endOfFrameData <= readingFrameData, false after minDelay;
          if verbosity > 0 then
            print(cr & "Advancing simulation to time " & frameLine.all);
          end if;
          delay := sscanf(frameLine.all);
          wait for delay - now;

        elsif command.all = "wait" then
          endOfFrameData <= readingFrameData, false after minDelay;
          wait for 2*minDelay;
          if verbosity > 0 then
            print(cr &"Advancing simulation of time " & frameLine.all);
          end if;
          delay := sscanf(frameLine.all);
          wait for delay - 3*minDelay;

        elsif command.all = "frame" then
          if verbosity > 0 then
            print("Reading frame data");
          end if;
          readingFrameData := true;
          sendCustomCrc <= false;
          rm_all_separators(frameLine);
          frameData := new string'(frameLine.all);

        elsif command.all = "crc" then
          rm_all_separators(frameLine);
          if verbosity > 0 then
            print("Selecting custom CRC: " & frameLine.all);
          end if;
          sendCustomCrc <= true;
          customCrc <= sscanf(frameLine.all);

        elsif ( (firstChar >= '0') and (firstChar <= '9') ) or
              ( (firstChar >= 'a') and (firstChar <= 'f') ) then
          rm_all_separators(frameLine);
          write(frameData, command.all);
          write(frameData, frameLine.all);
        end if;

      end if;
    end loop;
    file_close(frameFile);

    wait;
  end process parseFile;

  sendFrame: process
    variable completeFrame : line;
    variable sendHighByte : boolean;
    variable dataNibble : character;

    constant byteLength : positive := 8;
    variable crc          : std_ulogic_vector(crc32Polynom'range);
    variable crcXor       : std_ulogic_vector(crc32Polynom'range);
    variable crcData      : unsigned(7 downto 0);
    variable crcDataXor   : std_ulogic;
  begin
    mii_rxd  <= (others => 'Z');
    mii_rxdv <= '0';
    mii_rxer <= '0';
    mii_crs <= '0';

    wait until endOfFrameData;
                                                   -- calculate the Ethernet CRC
    if sendCustomCrc then
      crc := customCrc;
    else
      crc := (others => '1');
      sendHighByte := false;
      for index in frameData.all'left to frameData.all'right loop
        if not sendHighByte then
          dataNibble := frameData.all(index);
        else
          crcData := sscanf(dataNibble) & sscanf(frameData.all(index));
          for bit_index in 0 to 7 loop
            crcDataXor := crc(crc'high) xor crcData(bit_index);
            crcXor := crc(crc'high-1 downto 0) & '0';
            if crcDataXor = '1' then
              crcXor := crcXor xor crc32Polynom;
            end if;
            crc := crcXor;
          end loop;
        end if;
        sendHighByte := not sendHighByte;
      end loop;
      for byteIndex in 0 to (crc32Polynom'length/byteLength)-1 loop
        for bitIndex in 0 to byteLength-1 loop
          crcXor(byteLength*byteIndex + bitIndex) := crc(byteLength*byteIndex + byteLength-1-bitIndex);
        end loop;
      end loop;
      crc := not crcXor;
    end if;
                                                -- build complete Ethernet frame
    completeFrame := new string'("D5 ");
    write(completeFrame, frameData.all);
    write(completeFrame, " " & sprintf("%08X", crc));
    if verbosity > 0 then
      print("Sending frame data: " & completeFrame.all);
    end if;
    rm_all_separators(completeFrame);
                                                                -- send preamble
    wait until rising_edge(rxClock_int);
    mii_crs <= '1';
    
    ----------------------------------------------------------------------------
    -- 802.3-2012 - IEEE Standard for Ethernet 
    -- §22.2.2.7 RX_DV (Receive Data Valid)
    -- RX_DV  must  encompass  the  frame, starting no later than the Start
    -- Frame Delimiter (SFD) and excluding any End-of-Frame delimiter
    ----------------------------------------------------------------------------
    
    --------------------------------------------------------------------------
    -- Ethernet or Fast Ethernet (miiDataBitNb = 4)
    if miiDataBitNb = 4 then
      mii_rxd <= std_ulogic_vector(to_unsigned(5, mii_rxd'length));
      for index in 1 to 14 loop
        wait until rising_edge(rxClock_int);
      end loop;
                                                                   -- send frame
      sendHighByte := false;
      mii_rxdv <= '1';
      for index in completeFrame.all'left to completeFrame.all'right loop
        if index = errorArrivalIndex then
          if rxer_error then
            mii_rxer <= '1';
          end if;
          if rxdv_error then
            mii_rxdv <= '0';
          end if;
        else
          mii_rxdv <= '1';
          mii_rxer <= '0';
        end if;
        if sendHighByte then
          dataNibble := completeFrame.all(index-1);
        else
          dataNibble := completeFrame.all(index+1);
        end if;
        mii_rxd <= sscanf(dataNibble);
        wait until rising_edge(rxClock_int);
        sendHighByte := not sendHighByte;
      end loop;
    end if;   
    --------------------------------------------------------------------------
    -- Gigabit Ethernet (miiDataBitNb = 8)
    if miiDataBitNb = 8 then
      mii_rxd <= x"55";
      mii_rxdv <= '1';
      for index in 1 to 7 loop
        wait until rising_edge(rxClock_int);
      end loop;
                                                                   -- send frame
      sendHighByte := false;
      mii_rxdv <= '1';
      for index in completeFrame.all'left to completeFrame.all'right loop
        if index = 8 then
          if rxer_error then
            mii_rxer <= '1';
          end if;
          if rxdv_error then
            mii_rxdv <= '0';
          end if;
        else
          mii_rxdv <= '1';
          mii_rxer <= '0';
        end if;
        if sendHighByte then
          --nop
        else
          mii_rxd <= sscanf(completeFrame.all(index)) & sscanf(completeFrame.all(index+1));
          wait until rising_edge(rxClock_int);
        end if;
        sendHighByte := not sendHighByte;
      end loop;
    end if;

  end process sendFrame;

END ARCHITECTURE test;
