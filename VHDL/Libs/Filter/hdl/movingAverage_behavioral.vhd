--------------------------------------------------------------------------------
-- Copyright 2014 HES-SO Valais Wallis (www.hevs.ch)
--------------------------------------------------------------------------------
-- Moving Average Filter (MAF)
--   Calculates the average of the M last input samples:
--
--            x[n] + x[n-1] + .... + x[n-M+1]
--    y[n] =  -------------------------------
--                           M
--   the sum: h[n] = x[n] + x[n-1] + .... + x[n-M+1]
--   can also be defined as: h[n] = x[n] + h[n-1] - x[n-M]
--
--                         h[n]
--   and therefore: y[n] = ----
--                          M
--
--   this means the current sample is added  to the last sum and the M-last
--   sample is subtracted.
--   On clear the filter is initialized with 0. This means that the average will
--   be biased towards 0 for the firtst M samples.
--------------------------------------------------------------------------------
--  Authors: 
--    [Oliver A. Gubler](oliver.gubler@hevs.ch) guo
--------------------------------------------------------------------------------
--  History: 
--    v1.0 2014-04-29 guo
--      first release
--------------------------------------------------------------------------------
ARCHITECTURE behavioral OF movingAverage IS
  subtype sampleType is signed(sampleIn'range);
  type sampleTypeArray is array(natural range <>) of sampleType;
  signal sampleRegister: sampleTypeArray(1 to points);
  signal h: signed(sampleIn'high+requiredBitNb(points) downto sampleIn'low);
BEGIN
  
  -- shift register to memorize the M last samples
  shift_reg: process(reset, clock)
  begin
    if reset = '1' then
      sampleRegister <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if clear = '1' then
        sampleRegister <= (others => (others => '0'));
      elsif sampleEn = '1' then
        for i in points-1 downto 1 loop
          sampleRegister(i+1) <= sampleRegister(i);
        end loop;
        sampleRegister(1) <= sampleIn;
      end if;--sampleEn
    end if;--clock
  end process;
  
  -- accumulate, divide (and rule)
  sum: process(reset, clock)
  begin
    if reset = '1' then
      h <= (others => '0');
    elsif rising_edge(clock) then
      if clear = '1' then
        h <= (others => '0');
      elsif sampleEn = '1' then
        h <= sampleIn + h - sampleRegister(points);
      end if;
    end if;
  end process;

  averageOut <= resize(h/points,averageOut'length);
  
END ARCHITECTURE behavioral;

