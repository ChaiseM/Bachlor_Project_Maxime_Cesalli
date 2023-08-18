LIBRARY std;
  USE std.textio.all;
LIBRARY COMMON_TEST;
  USE COMMON_TEST.testUtils.all;

ARCHITECTURE test OF miiToRam_tester IS

  constant clockFrequency: real := 66.0E6;
  constant clockPeriod: time := (1.0/clockFrequency) * 1 sec;
  signal clock_int: std_ulogic := '1';
  signal reset_int: std_ulogic;

  constant max_frame_length: positive := 1518;
  constant byte_length: positive := 8;

  constant samplingPeriod: time := 10*clockPeriod;
  constant frame_length_bit_nb: positive := 11;  -- max payload = 1500 bytes
  constant error_bit_nb: positive := 3;
  signal read_frames: std_ulogic;
  signal read_byte: std_ulogic := '0';
  signal address_increment: integer;
  signal rx_data_byte: unsigned(byte_length-1 downto 0);
  signal jump_frame: std_ulogic := '0';
  signal frame_length : natural;
  signal rx_baseAddress_int: natural := 0;
  signal rx_address_int: natural := 0;

  signal tx_address_int: natural := 0;
  signal tx_data_unsigned: unsigned(tx_data'range);
  signal tx_data_byte: unsigned(byte_length-1 downto 0);
  signal write_byte: std_ulogic := '0';
  signal write_end_of_frame: std_ulogic;

  constant tab: string(1 to 64) := (others => ' ');
  constant indent: string(1 to 2) := (others => ' ');

BEGIN
  ------------------------------------------------------------------------------
                                                              -- Reset and clock
  reset_int <= '1', '0' after 2*clockPeriod;
  reset <= reset_int;

  clock_int <= not clock_int after clockPeriod/2;
  clock <= transport clock_int after clockPeriod*9/10;

  ------------------------------------------------------------------------------
                                                               -- Receive frames
  read_frames <= '1',
                 '0' after  50 us,
                 '1' after 320 us;

  read_RAM: process
    variable frame_ready : boolean;
    variable frame_error : natural;
    variable destination_mac_address : unsigned(6*8-1 downto 0);
    variable source_mac_address : unsigned(destination_mac_address'range);
    variable ethertype : unsigned(2*8-1 downto 0);
    variable ip_header_length : unsigned(3 downto 0);
    variable ip_protocol : unsigned(7 downto 0);
    variable ip_source_address : unsigned(31 downto 0);
    variable ip_destination_address : unsigned(ip_source_address'range);
  begin
    frame_ready := false;

    while not frame_ready loop
      wait for samplingPeriod;
      frame_ready := (rx_data(rx_data'high) = '1');
    end loop;

    if read_frames = '0' then
      wait until read_frames = '1';
    end if;
                                                                     -- Ethernet
    frame_length <= to_integer(unsigned(rx_data(frame_length_bit_nb-1 downto 0)));
    wait for 0 ns;
    frame_error :=
      to_integer(
        shift_right(
          unsigned(rx_data(rx_data'high-1 downto 0)),
          rx_data'length - error_bit_nb - 1
        )
      );
    if rxVerbosity > 0 then
      print(cr & tab & "New incoming frame at time " & sprintf("%8.3tu", now));
      print(tab & "Frame length: " & sprintf("%03X", frame_length));
      print(tab & "Frame error: " & sprintf("%03b", frame_error));

      if frame_error = 0 then
        destination_mac_address := (others => '0');
        address_increment <= 1;
        for index in 1 to rx_data'length/byte_length loop
          read_byte <= '1', '0' after 1 ns;
          wait until rising_edge(clock_int);
        end loop;
        for index in 1 to destination_mac_address'length/byte_length loop
          read_byte <= '1', '0' after 1 ns;
          wait until rising_edge(clock_int);
          wait for 1 ns;
          destination_mac_address := shift_left(destination_mac_address, byte_length);
          destination_mac_address(rx_data_byte'range) := rx_data_byte;
        end loop;
        print(
          tab & indent &
          "Destination MAC address: " & sprintf("%012X", destination_mac_address)
        );

        source_mac_address := (others => '0');
        for index in 1 to source_mac_address'length/byte_length loop
          read_byte <= '1', '0' after 1 ns;
          wait until rising_edge(clock_int);
          wait for 1 ns;
          source_mac_address := shift_left(source_mac_address, byte_length);
          source_mac_address(rx_data_byte'range) := rx_data_byte;
        end loop;
        print(
          tab & indent &
          "Source MAC address: " & sprintf("%012X", source_mac_address)
        );

        ethertype := (others => '0');
        for index in 1 to ethertype'length/byte_length loop
          read_byte <= '1', '0' after 1 ns;
          wait until rising_edge(clock_int);
          wait for 1 ns;
          ethertype := shift_left(ethertype, byte_length);
          ethertype(rx_data_byte'range) := rx_data_byte;
        end loop;
                                                                         -- IPv4
        if ethertype = 16#0800# then
          print(tab & indent & "Ethertype: 0800 / IPv4");
          read_byte <= '1', '0' after 1 ns;
          wait until rising_edge(clock_int);
          wait for 1 ns;
          ip_header_length :=
            resize(
              shift_right(
                unsigned(rx_data),
                rx_data'length - 8
              ),
              ip_header_length'length
            );
          print(
            tab & indent & indent &
            "Header length: " & sprintf("%02X", ip_header_length)
          );

          address_increment <= 9;
          read_byte <= '1', '0' after 1 ns;
          wait until rising_edge(clock_int);
          wait for 1 ns;
          ip_protocol :=
            resize(
              shift_right(
                unsigned(rx_data),
                rx_data'length - 16
              ),
              ip_protocol'length
            );

          address_increment <= 3;
          read_byte <= '1', '0' after 1 ns;
          wait until rising_edge(clock_int);
          address_increment <= 1;
          ip_source_address := (others => '0');
            for index in 1 to ip_source_address'length/byte_length loop
            read_byte <= '1', '0' after 1 ns;
            wait until rising_edge(clock_int);
            wait for 1 ns;
            ip_source_address := shift_left(ip_source_address, byte_length);
            ip_source_address(rx_data_byte'range) := rx_data_byte;
          end loop;
          print(
           tab & indent & indent &
           "Source IP address: " & sprintf("%08X", ip_source_address)
          );

          ip_destination_address := (others => '0');
          for index in 1 to ip_destination_address'length/byte_length loop
            read_byte <= '1', '0' after 1 ns;
            wait until rising_edge(clock_int);
            wait for 1 ns;
            ip_destination_address := shift_left(ip_destination_address, byte_length);
            ip_destination_address(rx_data_byte'range) := rx_data_byte;
          end loop;
          print(
            tab & indent & indent &
            "Destination IP address: " & sprintf("%08X", ip_destination_address)
          );
                                                                         -- ICMP
          if ip_protocol = 16#01# then
            print(
              tab & indent & indent &
              "IP protocol: 01 / ICMP (ping)"
            );
          else
            print(
              tab & indent & indent &
              "IP protocol: " & sprintf("%02X", ip_protocol)
            );
          end if;
        else
          print(
            tab & indent &
            "Ethertype: " & sprintf("%04X", ethertype)
          );
        end if;
      end if;
    end if;

    jump_frame <= '1', '0' after 1 ns;
    wait for 1 ns;

  end process read_RAM;

  ------------------------------------------------------------------------------
                                                              -- Transmit frames
  write_RAM: process
    constant frame_number: positive := 3;
    constant ping_byte_count : positive := 32;
    variable frame : unsigned(1 to max_frame_length);
    variable frame_length : natural;
    variable frameLine : line;
    variable destination_mac_address : unsigned(6*8-1 downto 0);
    variable source_mac_address : unsigned(destination_mac_address'range);
    variable ethertype : unsigned(2*8-1 downto 0);
    variable ip_version : unsigned(3 downto 0) := X"4";
    variable ip_header_length : unsigned(3 downto 0) := X"5";
    variable ip_total_length : unsigned(15 downto 0);
    variable ip_identification : unsigned(15 downto 0);
    variable ip_fragment : unsigned(15 downto 0);
    variable ip_time_to_live : unsigned(7 downto 0);
    variable ip_protocol : unsigned(7 downto 0);
    variable ip_header_checksum : unsigned(15 downto 0);
    variable ip_source_address : unsigned(31 downto 0);
    variable ip_destination_address : unsigned(ip_source_address'range);
    variable ping_header : unsigned(63 downto 0);
    variable ping_data : unsigned(7 downto 0);
  begin
    write_end_of_frame <= '0';
    wait until reset_int = '0';
                                                   -- Initialize status register
    tx_data_byte <= (others => '0');
    for index in 1 to tx_data'length / byte_length loop
      write_byte <= '1', '0' after 1 ns;
      wait until rising_edge(clock_int);
    end loop;
    wait for 0.5 us;
                                                                  -- Send frames
    for index in 1 to frame_number loop
      if txVerbosity > 0 then
        print(cr &"Sending new frame at time " & sprintf("%8.3tu", now));
      end if;
                                                                     -- Ethernet
      frame_length := 0;

      destination_mac_address := X"F04DA233B7EF";
      frame(1 to destination_mac_address'length) := destination_mac_address;
      frame_length := frame_length + destination_mac_address'length;

      source_mac_address := X"002564C26F6A";
      frame(frame_length+1 to frame_length+source_mac_address'length) := source_mac_address;
      frame_length := frame_length + source_mac_address'length;

      ethertype := X"0800";
      frame(frame_length+1 to frame_length+ethertype'length) := ethertype;
      frame_length := frame_length + ethertype'length;

      frame(frame_length+1 to frame_length+byte_length) := ip_version & ip_header_length;
      frame_length := frame_length + byte_length;

      frame(frame_length+1 to frame_length+byte_length) := (others => '0');
      frame_length := frame_length + byte_length;

      ip_total_length := X"003C";
      frame(frame_length+1 to frame_length+ip_total_length'length) := ip_total_length;
      frame_length := frame_length + ip_total_length'length;

      ip_identification := X"3198";
      frame(frame_length+1 to frame_length+ip_identification'length) := ip_identification;
      frame_length := frame_length + ip_identification'length;

      ip_fragment := (others => '0');
      frame(frame_length+1 to frame_length+ip_fragment'length) := ip_fragment;
      frame_length := frame_length + ip_fragment'length;

      ip_time_to_live := X"80";
      frame(frame_length+1 to frame_length+ip_time_to_live'length) := ip_time_to_live;
      frame_length := frame_length + ip_time_to_live'length;

      ip_protocol := X"01";
      frame(frame_length+1 to frame_length+ip_protocol'length) := ip_protocol;
      frame_length := frame_length + ip_protocol'length;

      ip_header_checksum := X"CADA";
      frame(frame_length+1 to frame_length+ip_header_checksum'length) := ip_header_checksum;
      frame_length := frame_length + ip_header_checksum'length;

      ip_source_address := X"996D05E0";
      frame(frame_length+1 to frame_length+ip_source_address'length) := ip_source_address;
      frame_length := frame_length + ip_source_address'length;

      ip_destination_address := X"996D0594";
      frame(frame_length+1 to frame_length+ip_destination_address'length) := ip_destination_address;
      frame_length := frame_length + ip_destination_address'length;

      ping_header := X"0800D55B04007400";
      frame(frame_length+1 to frame_length+ping_header'length) := ping_header;
      frame_length := frame_length + ping_header'length;

      ping_data := X"61";
      for index in 1 to ping_byte_count loop
        frame(frame_length+1 to frame_length+byte_length) := ping_data;
        frame_length := frame_length + byte_length;
        if ping_data < X"77" then
          ping_data := ping_data + 1;
        else
          ping_data := X"61";
        end if;
      end loop;

      frameLine := new string'("");
      wait until rising_edge(clock_int);
      for index in 1 to frame_length/byte_length loop
        tx_data_byte <= frame(1 to byte_length);
        write_byte <= '1', '0' after 1 ns;
        wait until rising_edge(clock_int);
        frame := shift_left(frame, byte_length);
        write(frameLine, sprintf("%02X", tx_data_byte));
      end loop;
      if txVerbosity > 0 then
        print(indent & "Frame data: " & frameLine.all);
      end if;

      write_end_of_frame <= '1', '0' after 1 ns;

      wait for 2.5 us;
    end loop;

  end process write_RAM;

  --============================================================================
                                                -- Read byte from incoming frame
  read_ram_byte: process
    constant ram_byte_width : positive := rx_data'length / byte_length;
    variable byte_address : natural := 0;
    variable data_offset : natural := 0;
  begin
    wait on read_byte, jump_frame;
    if rising_edge(read_byte) then
      byte_address := byte_address + address_increment;
      rx_address_int <= byte_address / ram_byte_width;
      data_offset := byte_address mod ram_byte_width;
      wait until rising_edge(clock_int);
      rx_data_byte <=
        resize(
          shift_right(
            unsigned(rx_data),
            (ram_byte_width - 1 - data_offset) * byte_length
          ),
          byte_length
        );
      wait for 0 ns;
    elsif rising_edge(jump_frame) then
      rx_baseAddress_int <= rx_baseAddress_int + (frame_length+1)/2 + 1;
      wait for 0 ns;
      byte_address := rx_baseAddress_int * ram_byte_width;
      rx_address_int <= rx_baseAddress_int;
    end if;
  end process read_ram_byte;

--  rx_baseAddress <= to_unsigned(rx_baseAddress_int, rx_baseAddress'length);
--  rx_address <= to_unsigned(rx_address_int, rx_address'length);
  rx_baseAddress <= resize(to_unsigned(rx_baseAddress_int, 32), rx_baseAddress'length);
  rx_address <= resize(to_unsigned(rx_address_int, 32), rx_address'length);

  ------------------------------------------------------------------------------
                                                 -- Write byte to outgoing frame
  write_ram_byte: process
    constant ram_byte_width : positive := tx_data'length / byte_length;
    variable frame_start_address : natural := 0;
    variable frame_end_address : natural;
    variable byte_address : natural := 0;
    variable data_offset : natural := 0;
  begin
    tx_write <= '0';
    wait on write_byte, write_end_of_frame;
    if rising_edge(write_byte) then
      data_offset := byte_address mod ram_byte_width;
      tx_data_unsigned <= shift_left(tx_data_unsigned, byte_length);
      wait for 0 ns;
      tx_data_unsigned(tx_data_byte'range) <= tx_data_byte;
      tx_address_int <= byte_address / ram_byte_width;
      if data_offset = ram_byte_width-1 then
        tx_write <= '1';
        wait until rising_edge(clock_int);
      end if;
      byte_address := byte_address + 1;
    elsif rising_edge(write_end_of_frame) then
      frame_end_address := tx_address_int;
      tx_address_int <= tx_address_int + 1;
      tx_data_unsigned <= (others => '0');
      tx_write <= '1';
      wait until rising_edge(clock_int);
      byte_address := byte_address + ram_byte_width;
      tx_address_int <= frame_start_address;
      tx_data_unsigned <= to_unsigned(frame_end_address - frame_start_address, tx_data_unsigned'length);
      tx_data_unsigned(tx_data_unsigned'high) <= '1';
      tx_write <= '1';
      wait until rising_edge(clock_int);
      frame_start_address := frame_end_address + 1;
    end if;
  end process write_ram_byte;

  tx_data <= std_ulogic_vector(tx_data_unsigned);
--  tx_address <= to_unsigned(tx_address_int, tx_address'length);
  tx_address <= resize(to_unsigned(tx_address_int, 32), tx_address'length); -- no warnings

END ARCHITECTURE test;
