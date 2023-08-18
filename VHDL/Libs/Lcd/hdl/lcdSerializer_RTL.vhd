library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF lcdSerializer IS

  ------------------------------------------------------------------------------
  -- The clock-pulse rate of the SCL line can be up to 20 MHz @3.3V
  --    The clock frequency is divided by generic value "baudRateDivide"
  --    The corresponding "sclEn" is further divided by 2 to generate SCL
  --
  signal sclCounter: unsigned(requiredBitNb(baudRateDivide-1)-1 downto 0);
	signal sclEn: std_ulogic;
	signal scl_int: std_ulogic;

  ------------------------------------------------------------------------------
  -- The minimal reset pulse width is 1 us
  --    "sclEn" at 40 MHz has to be divided by 40 to generate the 1 us delay
  --
	constant resetCount : natural := 40;
  signal resetCounter: unsigned(requiredBitNb(2*resetCount-1)-1 downto 0);
	signal resetDone: std_ulogic;


  ------------------------------------------------------------------------------
  -- Serial data bits have to be stable at the rising edge of SCL
  --    Data bits will be updated at the falling edge of SCL
  --
  -- Data in comprises 9 bits: A0 (as MSB) and 8 row pixels or command bits
  -- A0 selects between command data (A0 = 0) and pixel data (A0 = 1)
  --
	constant pixelsPerColumn : positive := data'length-1;
	signal dataSampled : std_ulogic_vector(data'range);
	signal chipSelect : std_ulogic;
	signal updateData: std_ulogic;
  signal dataCounter: unsigned(requiredBitNb(pixelsPerColumn+1)-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                        -- clock divider for SCL
  divideClock: process(reset, clock) 
	begin
    if reset='1' then
			scl_int <= '0';
      sclCounter <= (others => '0');
    elsif rising_edge(clock) then
      if sclEn = '1' then
        sclCounter <= (others => '0');
				scl_int <= not scl_int;
      else
        sclCounter <= sclCounter + 1;
			end if;
    end if;
  end process divideClock;

  sclEn <= '1' when sclCounter = baudRateDivide-1
    else '0';

  ------------------------------------------------------------------------------
                                                                    -- LCD reset
	process(clock,reset)
		variable i : natural;
	begin
		if reset = '1' then
			resetCounter <= (others => '0');
		elsif rising_edge(clock) then
			if sclEn = '1' then
  			if resetDone = '0' then
  				resetCounter <= resetCounter + 1;
  			end if;
			end if;
		end if;
	end process;

  resetDone <= '1' when resetCounter >= 2*resetCount-1
    else '0';
  RST_n <= '1' when resetCounter >= resetCount-1
    else '0';

  ------------------------------------------------------------------------------
                                                            -- sample input data
  process (reset, clock)
  begin
    if reset = '1' then
      dataSampled <= (others => '0');
    elsif rising_edge(clock) then
      if send = '1' then
        dataSampled <= data;
      end if;
    end if;
	end process;

  ------------------------------------------------------------------------------
                                                                           -- A0
	A0 <= dataSampled(data'high);

  ------------------------------------------------------------------------------
                                                               -- serialize data
  updateData <= sclEn and scl_int;

  process (reset, clock)
  begin
    if reset = '1' then
      dataCounter <= (others => '0');
    elsif rising_edge(clock) then
      if resetDone = '1' then
        if dataCounter = 0 then
          if send = '1' then
            dataCounter <= to_unsigned(pixelsPerColumn+1, dataCounter'length);
          end if;
        else
          if updateData = '1' then
            dataCounter <= dataCounter - 1;
          end if;
        end if;
      end if;
    end if;
	end process;

  busy <= '1' when (resetDone = '0') or (dataCounter > 0)
    else '0';
	chipSelect <= '1' when (dataCounter > 0) and (dataCounter < pixelsPerColumn+1)
	  else '0';

	sampleData: process (reset, clock)
	begin
		if reset = '1' then
      CS_n <= '1';
      SCL  <= '1';
      SI   <= '1';
		elsif rising_edge(clock) then
			if chipSelect = '1' then
        CS_n <= '0';
        SCL <= scl_int or not(chipSelect);
				SI <= dataSampled(to_integer(dataCounter-1));
			else
        CS_n <= '1';
        SCL <= '1';
        SI <= '1';
			end if;
		end if;
	end process sampleData;

END ARCHITECTURE RTL;
