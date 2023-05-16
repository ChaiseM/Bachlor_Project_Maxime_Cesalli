LIBRARY ieee;
  USE ieee.math_real.ALL;

ARCHITECTURE test OF adc128S102_tester IS

  constant sclkFrequency : real := 16.0E6; 
  constant sclkPeriod : time := 1.0/sclkFrequency * 1 sec; 
  constant channelNb : positive := 8; 
  constant sampleFrequency : real := sclkFrequency / real(2*channelNb*(adcBitNb+4));
  constant samplePeriod : time := 1.0/sampleFrequency * 1 sec; 
  signal sampleEn : std_ulogic := '0';
  constant t_DH : time := 10 ns;
                                                                -- input signals
  constant in0Frequency : real := 0.0 * sampleFrequency/2.0;
  constant in1Frequency : real := 0.1 * sampleFrequency/2.0;
  constant in2Frequency : real := 0.2 * sampleFrequency/2.0;
  constant in3Frequency : real := 0.3 * sampleFrequency/2.0;
  constant in4Frequency : real := 0.4 * sampleFrequency/2.0;
  constant in5Frequency : real := 0.5 * sampleFrequency/2.0;
  constant in6Frequency : real := 0.6 * sampleFrequency/2.0;
  constant in7Frequency : real := 0.7 * sampleFrequency/2.0;
  constant signalAmplitude : real := 2.0**(adcBitNb-1) - 1.0;
  signal tReal: real := 0.0;
                                                                -- SPI interface
  signal sclk_int : std_ulogic := '0';
  signal channelId : natural;
  signal sampleChannel, sampleDone: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                                 -- serial clock
  sclk_int <= not sclk_int after sclkPeriod;
  sampleEn <= '0' after 1 ns when sampleEn = '1'
    else '1' after samplePeriod - 1 ns;

  ------------------------------------------------------------------------------
                                                                -- input signals
  process(sclk_int)
  begin
    if sclk_int'event then
      tReal <= tReal + 0.5/sclkFrequency;
    end if;
  end process;

  IN0 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in0Frequency*tReal))),
    IN0'length
  );
  IN1 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in1Frequency*tReal))),
    IN1'length
  );
  IN2 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in2Frequency*tReal))),
    IN2'length
  );
  IN3 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in3Frequency*tReal))),
    IN3'length
  );
  IN4 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in4Frequency*tReal))),
    IN4'length
  );
  IN5 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in5Frequency*tReal))),
    IN5'length
  );
  IN6 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in6Frequency*tReal))),
    IN6'length
  );
  IN7 <= to_unsigned(
    integer(signalAmplitude * (1.0 + sin(2.0*math_pi*in7Frequency*tReal))),
    IN7'length
  );

  ------------------------------------------------------------------------------
                                                                  -- SPI control
  sampleAllChannels: process
  begin
                                                          -- loop on 4 samplings
    for index in 1 to 4 loop
      channelId <= 0;
      sampleChannel <= '0';
      wait until rising_edge(sampleEn);
                                                         -- loop on all channels
      for channelIndex in 1 to channelNb loop
        sampleChannel <= '1', '0' after 1 ns;
        wait until sampleDone = '1';
        wait for 1 ns;
        channelId <= channelId + 1;
      end loop;
    end loop;
                                                            -- end of simulation
    wait for samplePeriod/4;
    assert false
      report "End of simulation"
      severity failure;
    wait;
  end process sampleAllChannels;
                                                   -- sample one of the channels
  sampleOneChannel: process
    variable shiftRegisterOut, shiftRegisterIn : unsigned(adcBitNb-1 downto 0);
  begin
    sampleDone <= '0';
    CS_n <= '1';
    DIN <= '0';
    wait until sampleChannel = '1';
    wait until rising_edge(sclk_int);
    wait for 1 ns;
                                                              -- start SPI frame
    CS_n <= '0';
                                                           -- prepare channel id
    shiftRegisterOut := shift_left(
      to_unsigned(channelId, shiftRegisterOut'length),
      adcBitNb-4
    );
                                               -- send SPI clocks and channel id
    for index in 1 to adcBitNb+4 loop
      wait until rising_edge(sclk_int);
      wait for t_DH;
      DIN <= shiftRegisterOut(shiftRegisterOut'high);
      shiftRegisterOut := shift_left(shiftRegisterOut, 1);
    end loop;
                                                          -- terminate SPI frame
    wait for sclkPeriod/4;
    sampleDone <= '1';
    wait for 1 ns;
  end process sampleOneChannel;

  SCLK <= '1' when CS_n = '1'
    else sclk_int;

END ARCHITECTURE test;
