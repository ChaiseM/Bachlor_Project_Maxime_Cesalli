library Common;
  use Common.CommonLib.all;

ARCHITECTURE sim OF adc128S102 IS
  constant channelNb : positive := 8; 
  type inputArrayType is array (1 to channelNb) of unsigned(adcBitNb-1 downto 0);
  signal inputArray : inputArrayType := (others => (others => '0'));
  signal channelId : natural;

BEGIN
  ------------------------------------------------------------------------------
                                                              -- inputs sampling
  sampleInputs: process
  begin
    wait until falling_edge(CS_n);
    for index in 1 to 3 loop
      wait until rising_edge(SCLK);
    end loop;
    inputArray(1) <= IN0;
    inputArray(2) <= IN1;
    inputArray(3) <= IN2;
    inputArray(4) <= IN3;
    inputArray(5) <= IN4;
    inputArray(6) <= IN5;
    inputArray(7) <= IN6;
    inputArray(8) <= IN7;
  end process sampleInputs;
                                                              -- read channel id
  readChannelId: process
    variable shiftRegister : unsigned(2 downto 0);
  begin
    wait until falling_edge(CS_n);
    for index in 1 to 2 loop
      wait until rising_edge(SCLK);
    end loop;
    for index in 1 to shiftRegister'length loop
      wait until falling_edge(SCLK);
      shiftRegister := shift_left(shiftRegister, 1);
      shiftRegister(shiftRegister'low) := DIN;
    end loop;
    channelId <= to_integer(shiftRegister) + 1;
  end process readChannelId;
                                                             -- shift out sample
  shiftOutSample: process
    variable shiftRegister : unsigned(adcBitNb-1 downto 0);
  begin
    DOUT <= '0';
    wait until falling_edge(CS_n);
    for index in 1 to 5 loop
      wait until falling_edge(SCLK);
    end loop;
    wait for 1 ns;
    shiftRegister := inputArray(channelId);
    for index in 1 to shiftRegister'length-1 loop
      DOUT <= shiftRegister(shiftRegister'high);
      wait for 1 ns;
      shiftRegister := shift_left(shiftRegister, 1);
      wait until falling_edge(SCLK);
    end loop;
    DOUT <= shiftRegister(shiftRegister'high);
    wait for 1 ns;
    wait until rising_edge(CS_n);
  end process shiftOutSample;

END ARCHITECTURE sim;