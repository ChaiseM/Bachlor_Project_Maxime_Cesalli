
------------------------------------------------------------------
-- Calculates the Xover filter witch the serial paralel approach.
-- Each clcock pulse, n calculation will be made => we can reduce
-- the calculation time by N. But the hardware usage is going to
-- be increased grately.
-------------------------------------------------------------------
architecture ParalelSym of Xover is
   -- constants
   constant HALF_FILTER_TAP_NB : positive := FILTER_TAP_NB/2 +
   (FILTER_TAP_NB mod 2);
   constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
   constant ACCUMULATOR_Bit_NB : positive := COEFF_BIT_NB + audioMono'LENGTH
    + FINAL_SHIFT;
   constant n : unsigned(cnt'range) := to_unsigned(2, cnt'length);
   constant remaining_calc : unsigned(cnt'range) := (HALF_FILTER_TAP_NB mod n);
   -- signals
   signal oldLRCK : std_ulogic;
   signal calculate : unsigned (2 downto 0);
   signal cnt : unsigned(FINAL_SHIFT - 1 downto 0);
   -- arrays
   type t_samples is array (0 to FILTER_TAP_NB - 1) of
   signed (audioMono'range); -- vector of FILTER_TAP_NB signed elements
   signal samples : t_samples;
   -- lowpass firtst then highpass coeff
   type coefficients is array (0 to 1, 0 to HALF_FILTER_TAP_NB - 1) of
   signed(COEFF_BIT_NB - 1 downto 0);
   signal coeff : coefficients := (
      (
      x"FFFF", x"0000", x"0000", x"0000", x"0000", x"0000",
      x"0001", x"0001", x"0001", x"0001", x"0000", x"FFFF",
      x"FFFD", x"FFF9", x"FFF5", x"FFF0", x"FFEC", x"FFEA",
      x"FFEC", x"FFF2", x"FFFD", x"000E", x"0025", x"003F",
      x"0059", x"006F", x"007C", x"0079", x"0063", x"0035",
      x"FFF1", x"FF97", x"FF30", x"FEC5", x"FE67", x"FE27",
      x"FE15", x"FE44", x"FEC1", x"FF94", x"00BC", x"0234",
      x"03EC", x"05CA", x"07B0", x"097E", x"0B11", x"0C4A",
      x"0D11", x"0D55"),
      (
      x"0000", x"0000", x"FFFF", x"FFFF", x"FFFF", x"FFFF",
      x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"0000",
      x"0003", x"0007", x"000B", x"0010", x"0014", x"0016",
      x"0014", x"000E", x"0003", x"FFF2", x"FFDB", x"FFC1",
      x"FFA7", x"FF91", x"FF84", x"FF87", x"FF9D", x"FFCB",
      x"000F", x"0069", x"00D0", x"013B", x"0199", x"01D9",
      x"01EB", x"01BC", x"013F", x"006C", x"FF44", x"FDCC",
      x"FC14", x"FA36", x"F850", x"F682", x"F4EF", x"F3B6",
      x"F2EF", x"72AA")
   );
   begin
   shiftSamplesAndMul : process (clock, reset)
      variable accumulator : signed (ACCUMULATOR_Bit_NB - 1 downto 0);
   begin
      if (reset = '1') then
         samples <= (others => (others => '0'));
         cnt <= (others => '0');
         calculate <= (others => '0');
         oldLRCK <= '0';
      elsif rising_edge(clock) then
         if en = '1' then
            -- calculate goes to 1 to enable the calculation of the samples
            calculate <= to_unsigned(2, calculate'length);
            -- shifting the registers
            -- the first info goes to samples 0
            samples(0) <= audioMono;
            -- loop to shift the samples
            shift : for ii in 0 to FILTER_TAP_NB - 2 loop
               samples(ii + 1) <= samples(ii);
            end loop shift;
         end if;
         if calculate > 0 then
            --if we arrive at the end of the calculation
            if cnt >= HALF_FILTER_TAP_NB - n then
               -- calculates the remaining tap(if any)
               if signed(remaining_calc) - 1 >= 0 then
                  do : for m in 0 to to_integer(signed(remaining_calc) - 1) loop
                     accumulator := accumulator + ((resize(samples
                     (to_integer(cnt + m)), audioMono'LENGTH + 1) +
                     samples(FILTER_TAP_NB - 1 - to_integer(cnt + m))) * coeff
                     (to_integer(calculate mod 2), to_integer(cnt + m)));
                  end loop do;
               end if;
               accumulator := accumulator + samples(HALF_FILTER_TAP_NB - 1)
               coeff(to_integer(calculate mod 2), HALF_FILTER_TAP_NB - 1);
               if (calculate mod 2) = 0 then
                  lowPass <= resize(shift_right(accumulator,
                     ACCUMULATOR_Bit_NB - Lowpass'LENGTH - 7), Lowpass'length);
               elsif (calculate mod 2) = 1 then
                  Highpass <= resize(shift_right(accumulator,
                     ACCUMULATOR_Bit_NB - Lowpass'LENGTH - 7), Lowpass'length);
               end if;
               cnt <= (others => '0');
               accumulator := (others => '0');
               calculate <= calculate - 1;
            else
               accumulator : for k in 0 to to_integer(n - 1) loop
                  accumulator := accumulator + ((resize(samples(
                  to_integer(cnt + k)), audioMono'LENGTH + 1) +
                  samples(FILTER_TAP_NB - 1 - to_integer(cnt + k))) * coeff(
                  to_integer(calculate mod 2), to_integer(cnt + k)));
               end loop accumulator;
               cnt <= cnt + n;
            end if;
         end if;
      end if;
   end process shiftSamplesAndMul;
   DataReady <= '1' when calculate = 0 else '0';
end architecture ParalelSym;