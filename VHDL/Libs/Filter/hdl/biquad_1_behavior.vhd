--
-- VHDL Architecture filters.biquad_1.behavior
--
-- Created:
--          by - Farquet Sébastien (HES-SO Valais)
--          at - 14:49:57 01.06.2010
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
ARCHITECTURE behavior OF biquad_1 IS

   ------------------------------------------------------------------------------
   -- Internal signals
   ------------------------------------------------------------------------------
   signal w1_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal w2_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal w3_s  : signed((data_size_g -1) downto 0); -- 16,15
   --     w4    : no signal because d2 = 0 => w4 = 0
   signal w5_s  : signed((data_size_g -1) downto 0); -- 16,14
   signal w6_s  : signed((data_size_g -1) downto 0); -- 16,14
   signal w7_s  : signed((data_size_g +5 -1) downto 0); -- 21,20
   --     w8    : no signal because two operation realized on the same time
   signal w9_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal w10_s : signed((data_size_g -1) downto 0); -- 16,15

   signal x1_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal x2_s  : signed((data_size_g -1) downto 0); -- 16,15
   ------------------------------------------------------------------------------

   BEGIN

   ------------------------------------------------------------------------------
   -- Update internal signals
   ------------------------------------------------------------------------------
   update_internal_signals: process(u_i, w1_s, w2_s, w3_s, w5_s, w6_s, w7_s, x1_s, x2_s)
   begin
      w1_s  <= u_i;
      w2_s  <= w1_s; -- 1 * w1_s
      w3_s  <= w1_s; -- 1 * w1_s

      w5_s  <= resize(shift_right((resize(x1_s, (data_size_g +1)) + resize(w2_s, (data_size_g +1))), 1), data_size_g);
      w6_s  <= w5_s + shift_right(w5_s, 6);
--      w7_s  <= shift_right(resize(w5_s, (data_size_g +5)), 1);
      w7_s  <= resize(w5_s, (data_size_g +5));
      
      w9_s  <= resize(resize(x2_s, (data_size_g +1)) + resize(w3_s, (data_size_g +1)) + resize(x1_s, (data_size_g +1)) - shift_left(resize(w6_s, (data_size_g +1)), 1), data_size_g);
      w10_s <= resize(shift_right((shift_left(resize(x2_s, (data_size_g +5)), 5) - w7_s), 5), data_size_g);
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

