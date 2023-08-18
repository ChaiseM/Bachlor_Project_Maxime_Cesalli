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
--------------------------------------------------------------------------------
-- miiReceiver test
--   
--------------------------------------------------------------------------------
--  Authors: 
--    cof: [François Corthay](francois.corthay@hevs.ch)
--    guo: [Oliver A. Gubler](oliver.gubler@hevs.ch)
--------------------------------------------------------------------------------
-- Changelog:
--   2015-06 : guo
--     update to be compatible with Gigabit Ethernet
--     added logSingleFile option
--------------------------------------------------------------------------------
LIBRARY std;
  USE std.textio.all;
LIBRARY COMMON_TEST;
  USE COMMON_TEST.testUtils.all;

ARCHITECTURE test OF miiReceiver IS

  constant clockFrequency: real := real(ethClockFrequency);
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal txClock_int: std_ulogic := '1';

  constant crcLength: positive := 4;

  constant tab: string(1 to 64) := (others => ' ');
  constant indent: string(1 to 2) := (others => ' ');

BEGIN
  ------------------------------------------------------------------------------
                                                                        -- clock
  txClock_int <= not txClock_int after clockPeriod/2;
  mii_txclk <= transport txClock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                                          -- CRS
  mii_crs <= mii_txen;

  ------------------------------------------------------------------------------
                                                             -- write frame file
  writeFile: process
    file frameFile : text;
    variable frameFileExt : line;
    variable frameFileSpec : line;
    variable frameCounter : positive := 1;
    variable frameLine : line;
    variable dataLine : line;
    variable endOfFrame : boolean;
    variable miiData : unsigned(mii_txd'range);
    variable miiByte : unsigned(7 downto 0);
    variable dataCounter : natural;
    variable preambleDone : boolean;
    variable cleanOutputFile : boolean := true;
  begin

    wait until mii_txen = '1';
    
    ----------------------------------------------------------------------------
    -- write frame info to file
    frameFileSpec := new string'(framesFileSpec);
    read_last(frameFileSpec, ".", frameFileExt);
    if logSingleFile then
      write(frameFileSpec, "." & frameFileExt.all);
    else
      write(frameFileSpec, sprintf("%d", frameCounter) & "." & frameFileExt.all);
    end if;
    if verbosity > 0 then
      print(tab & "Opening Ethernet frame file " & frameFileSpec.all);
    end if;
    if logSingleFile then
      if cleanOutputFile then
        file_open(frameFile, frameFileSpec.all, WRITE_MODE);
        cleanOutputFile := false;
    else
      file_open(frameFile, frameFileSpec.all, APPEND_MODE);
    end if;
    else
      file_open(frameFile, frameFileSpec.all, WRITE_MODE);
    end if;
    frameLine := new string'("at      " & sprintf("%tn", now));
    writeline(frameFile, frameLine);
    frameLine := new string'("info    frame " & sprintf("%d", frameCounter));
    writeline(frameFile, frameLine);
    
    ----------------------------------------------------------------------------
    -- write frame data to line
    preambleDone := false;
    dataCounter := 0;
    miiData := (others => '0');
    frameLine := new string'("");
    endOfFrame := false;
    -- Ethernet or Fast Ethernet (miiDataBitNb = 4)
    if miiDataBitNb = 4 then
      if verbosity > 0 then
        print(tab & "Detecting Ethernet or Fast Ethernet");
      end if;
      while not endOfFrame loop
        wait until falling_edge(txClock_int);
        if mii_txen = '0' then
          endOfFrame := true;
        else
          if (dataCounter mod 2) = 0 then
            miiData := unsigned(mii_txd);
          else
            miiByte := unsigned(mii_txd) & miiData;
            if verbosity > 0 then
              print(tab & "MII Byte " & sprintf("%03d", dataCounter) & " -> " & sprintf("%02X", miiByte));
            end if;
            if preambleDone then
              write(frameLine, sprintf("%02X", miiByte));
            end if;
            if miiByte = X"D5" then
              preambleDone := true;
              if verbosity > 0 then
                print(tab & "Preamble done");
              end if;
            end if;
          end if;
        end if;
        dataCounter := dataCounter + 1;
      end loop;
    end if;
    -- Gigabit Ethernet (miiDataBitNb = 8)
    if miiDataBitNb = 8 then
      if verbosity > 0 then
        print(tab & "Detecting Gigabit Ethernet");
      end if;
      while not endOfFrame loop
        wait until falling_edge(txClock_int);
        if mii_txen = '0' then
          endOfFrame := true;
        else
          miiByte := unsigned(mii_txd);
          if preambleDone then
            write(frameLine, sprintf("%02X", miiByte));
          end if;
          if miiByte = X"d5" then
            preambleDone := true;
          end if;
        end if;
        dataCounter := dataCounter + 1;
      end loop;
    end if;

    ----------------------------------------------------------------------------
    -- write frame data to file
    dataCounter := 1;
    dataLine := new string'("frame   ");
    for index in 0 to frameLine'length/2-crcLength-1 loop
      write(dataLine, frameLine(2*index+1) & frameLine(2*index+2));
      if dataCounter < 16 then
        write(dataLine, string'(" "));
      else
        writeline(frameFile, dataLine);
        dataCounter := 0;
        dataLine := new string'("        ");
      end if;
      dataCounter := dataCounter + 1;
    end loop;
    writeline(frameFile, dataLine);

    ----------------------------------------------------------------------------
    -- write crc to file
    dataLine := new string'("crc     ");
    write(dataLine, frameLine(frameLine'length-2*crcLength+1 to frameLine'length));
    writeline(frameFile, dataLine);
    if logSingleFile then
      writeline(frameFile, dataLine);
    end if;

    file_close(frameFile);
    frameCounter := frameCounter + 1;
  end process writeFile;

END ARCHITECTURE test;
