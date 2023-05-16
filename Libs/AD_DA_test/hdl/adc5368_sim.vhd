ARCHITECTURE sim OF adc5368 IS

  signal controlPortMode: boolean := false;
  signal masterMode: boolean := false;

  constant oscFrequency : real := 49.152E6;
  constant oscPeriod : time := 1.0/oscFrequency * 1 sec;
  signal oscClock: std_ulogic := '0';

  signal clockDivider1: positive := 2;
  signal clockDivider2: positive := 1;
  signal clockDivider: positive;
  
  signal sclk_int: std_ulogic := '0';
  signal lrck_int: std_ulogic := '0';

  constant channelNb : positive := 8; 
  subtype sampleRegType is signed(signalBitNb-1 downto 0);
  type valuesArrayType is array (1 to channelNb) of integer;
  type sampleArrayType is array (1 to channelNb) of sampleRegType;

  signal sampleEn : std_ulogic := '0';
  signal aIn: valuesArrayType;
  signal aInSampled: sampleArrayType := (others => (others => '0'));
  signal aInReg: sampleArrayType := (others => (others => '0'));

  signal lrck_delayed : std_ulogic;
  signal lrck_changed : std_ulogic;

BEGIN

  ------------------------------------------------------------------------------
                                                                       -- Clocks
  --oscClock <= not oscClock after oscPeriod/2;
  mclk <= 'Z' when externalClock = true else oscClock;

  setPrescalerValue: process(controlPortMode, clkmode, mdiv)
    variable controlBits: std_ulogic_vector(1 to 2);
  begin
    if controlPortMode = false then
      controlBits := clkmode & mdiv;
      case controlBits is
        when "00" => clockDivider1 <= 2 * 1;
        when "01" => clockDivider1 <= 2 * 2;
        when "10" => clockDivider1 <= 3 * 1;
        when "11" => clockDivider1 <= 3 * 2;
        when others => null;
      end case;
    end if;
  end process setPrescalerValue;

  setSpeedScalerValue: process(masterMode, clkmode, mdiv)
    variable controlBits: std_ulogic_vector(1 to 2);
  begin
    if masterMode = false then
      controlBits := m1_scl_cclk & m0_sda_cdout;
      case controlBits is
        when "00" => clockDivider2 <= 4;
        when "01" => clockDivider2 <= 2;
        when "10" => clockDivider2 <= 1;
        when others => null;
      end case;
    end if;
  end process setSpeedScalerValue;

  clockDivider <= clockDivider1 * clockDivider2;

  divideMclk: process
  begin
    for index in 1 to clockDivider loop
      wait until mclk'event;
    end loop;
    sclk_int <= not sclk_int;
  end process divideMclk;

  sclk <= sclk_int;

  divideSclk: process
  begin
    for index in 1 to 63 loop
      wait until sclk'event;
    end loop;
    wait until falling_edge(sclk);
    lrck_int <= not lrck_int;
  end process divideSclk;

  lrck_fs <= lrck_int;

  ------------------------------------------------------------------------------
                                                              -- Signal sampling
  buildSampleEn: process
    variable controlBits: std_ulogic_vector(1 to 2);
  begin
    controlBits := dif1_ad1_cdin & dif0_ad0_cs_n;
    if controlBits = "01" then
      wait until lrck_int = '1';
      sampleEn <= '1', '0' after 1 ns;
    else
      wait until lrck_int = '0';
      sampleEn <= '1', '0' after 1 ns;
    end if;
  end process buildSampleEn;

  aIn <= (aIn1, aIn2, aIn3, aIn4, aIn5, aIn6, aIn7, aIn8);

  sampleSignals: process(sampleEn)
  begin
    if rising_edge(sampleEn) then
      for index in aIn'range loop
        aInSampled(index) <= to_signed(aIn(index), aInSampled(index)'length);
      end loop;
    end if;
  end process sampleSignals;

  ------------------------------------------------------------------------------
                                                            -- Output serializer
  process(sclk)
  begin
    if falling_edge(sclk) then
      lrck_delayed <= lrck_int;
    end if;
  end process;

  lrck_changed <= '1' when lrck_delayed /= lrck_int else '0';

  process(sclk_int)
  begin
    if falling_edge(sclk_int) then
      if lrck_changed = '1' then
        aInReg <= aInSampled;
      else
        for index in aInReg'range loop
          aInReg(index) <= shift_left(aInReg(index), 1);
        end loop;
      end if;
    end if;
  end process;

  sdout1_tdm   <= aInReg(1)(aInReg(1)'high) when lrck_int = '0'
             else aInReg(2)(aInReg(2)'high);
  sdout2       <= aInReg(3)(aInReg(3)'high) when lrck_int = '0'
             else aInReg(4)(aInReg(4)'high);
  sdout3_tdm_n <= aInReg(5)(aInReg(5)'high) when lrck_int = '0'
             else aInReg(6)(aInReg(6)'high);
  sdout4       <= aInReg(7)(aInReg(7)'high) when lrck_int = '0'
             else aInReg(8)(aInReg(8)'high);

  ovfl_n <= '0';
  m0_sda_cdout <= 'Z';

END ARCHITECTURE sim;
