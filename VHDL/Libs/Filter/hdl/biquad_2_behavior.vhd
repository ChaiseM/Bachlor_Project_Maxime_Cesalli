--
-- VHDL Architecture filters.biquad_2.behavior
--
-- Created:
--          by - Farquet Sébastien (HES-SO Valais)
--          at - 16:18:12 01.06.2010
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
ARCHITECTURE behavior OF biquad_2 IS

   ------------------------------------------------------------------------------
   -- Internal signals
   ------------------------------------------------------------------------------
   signal w1_s  : signed((data_size_g -1) downto 0); -- 16,14
   signal w2_s  : signed((data_size_g -1) downto 0); -- 16,14
   signal w3_s  : signed((data_size_g +15 -1) downto 0); -- 31,30
   signal w4_s  : signed((data_size_g +15 -1) downto 0); -- 31,30
   signal w5_s  : signed((data_size_g -1) downto 0); -- 16,14
   signal w6_s  : signed((data_size_g + 6 -1) downto 0); -- 22,21
   signal w7_s  : signed((data_size_g +12 -1) downto 0); -- 28,27
   --     w8    : no signal because two operation realized on the same time
   signal w9_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal w10_s : signed((data_size_g + 6 -1) downto 0); -- 22,21

   signal x1_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal x2_s  : signed((data_size_g + 6 -1) downto 0); -- 22,21


-- -- Farks: Modification => w9, 16,14
   -- signal w1_s  : signed((data_size_g -1) downto 0); -- 16,14
   -- signal w2_s  : signed((data_size_g -1) downto 0); -- 16,14
   -- signal w3_s  : signed((data_size_g +15 -1) downto 0); -- 31,30
   -- signal w4_s  : signed((data_size_g +15 -1) downto 0); -- 31,30
   -- signal w5_s  : signed((data_size_g -1) downto 0); -- 16,14
   -- signal w6_s  : signed((data_size_g + 6 -1) downto 0); -- 22,21
   -- signal w7_s  : signed((data_size_g +12 -1) downto 0); -- 28,27
   -- --     w8    : no signal because two operation realized on the same time
   -- signal w9_s  : signed((data_size_g -1) downto 0); -- 16,14
   -- signal w10_s : signed((data_size_g + 6 -1) downto 0); -- 22,21

   -- signal x1_s  : signed((data_size_g -1) downto 0); -- 16,14
   -- signal x2_s  : signed((data_size_g + 6 -1) downto 0); -- 22,21
   ------------------------------------------------------------------------------

   BEGIN

   ------------------------------------------------------------------------------
   -- Update internal signals
   ------------------------------------------------------------------------------
   update_internal_signals: process(u_i, w1_s, w2_s, w3_s, w4_s, w5_s, w6_s, w7_s, x1_s, x2_s)
   begin
      w1_s  <= u_i;
      w2_s  <= w1_s; -- 1 * w1_s
      --w3_s  <= shift_right(resize(w1_s, (data_size_g +15)), 1);
      w3_s  <= resize(w1_s, (data_size_g +15));
      w4_s  <= w3_s; --w4_s <= shift_right(resize(w1_s, (data_size_g +15)), 1);
      w5_s  <= resize(shift_right((resize(x1_s, (data_size_g +1)) + shift_left(resize(w2_s, (data_size_g +1)), 1)), 1), data_size_g);
      --w6_s  <= shift_right(resize(w5_s, (data_size_g +6)), 1);
      w6_s  <= resize(w5_s, (data_size_g +6));
      --w7_s  <= shift_right(resize(w5_s, (data_size_g +12)), 1);
      w7_s  <= resize(w5_s, (data_size_g +12));
      
      w9_s  <= resize(shift_right(shift_left(resize(x2_s, (data_size_g +15)), 9) + w3_s + shift_left(resize(x1_s, (data_size_g +15)), 15) - shift_left(resize(w6_s, (data_size_g +15)), 9), 15), data_size_g);
      w10_s <= resize(shift_right(w4_s + shift_left(resize(x2_s, (data_size_g +15)), 9) - shift_left(resize(w7_s, (data_size_g +15)), 3), 9), (data_size_g + 6));

-- -- Farks: Modification => w9, 16,14
      -- w1_s  <= u_i;
      -- w2_s  <= w1_s; -- 1 * w1_s
-- --      w3_s  <= shift_right(resize(w1_s, (data_size_g +15)), 1);
      -- w3_s  <= resize(w1_s, (data_size_g +15));
      -- w4_s  <= w3_s; --w4_s <= shift_right(resize(w1_s, (data_size_g +15)), 1);
      -- w5_s  <= x1_s + w2_s;
-- --      w6_s  <= shift_right(resize(w5_s, (data_size_g +6)), 1);
      -- w6_s  <= resize(w5_s, (data_size_g +6));
-- --      w7_s  <= shift_right(resize(w5_s, (data_size_g +12)), 1);
      -- w7_s  <= resize(w5_s, (data_size_g +12));
      
      -- w9_s  <= resize(shift_right(shift_left(resize(x2_s, (data_size_g +16)), 9) + resize(w3_s, (data_size_g +16)) + shift_left(resize(x1_s, (data_size_g +16)), 16) - shift_left(resize(w6_s, (data_size_g +16)), 9), 16), data_size_g);
      -- w10_s <= resize(shift_right(w4_s + shift_left(resize(x2_s, (data_size_g +15)), 9) - shift_left(resize(w7_s, (data_size_g +15)), 3), 9), (data_size_g + 6));
   end process update_internal_signals;
   ------------------------------------------------------------------------------

   ------------------------------------------------------------------------------
   -- Update internal registers
   ------------------------------------------------------------------------------
   update_internal_registers: process(clock_i, reset_i)
   begin
      if reset_i = '1' then
         x1_s <= (others => '0');
         x2_s <= (others => '0');
      elsif rising_edge(clock_i) then
         if enable_i = '1' then
            x1_s <= w9_s;
            x2_s <= w10_s;
         end if;
      end if;
   end process update_internal_registers;
   ------------------------------------------------------------------------------

   ------------------------------------------------------------------------------
   -- Update output
   ------------------------------------------------------------------------------
   update_output: process(w5_s)
   begin
      y_o <= w5_s;
   end process update_output;
   ------------------------------------------------------------------------------

END ARCHITECTURE behavior;

