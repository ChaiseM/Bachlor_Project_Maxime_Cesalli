--
-- VHDL Architecture filters.biquad_1.simplified
--
-- Created:
--          by - Farquet Sébastien (HES-SO Valais)
--          at - 08:36:03 09.06.2010
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
ARCHITECTURE simplified OF biquad_1 IS

   ------------------------------------------------------------------------------
   -- Internal signals
   ------------------------------------------------------------------------------
   signal w1_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal w2_s  : signed((data_size_g -1) downto 0); -- 16,15
   --     w3    : no signal because d1 = 0 => w3 = 0
   --     w4    : no signal because d2 = 0 => w4 = 0
   signal w5_s  : signed((data_size_g -1) downto 0); -- 16,15
   signal w6_s  : signed((data_size_g +6 -1) downto 0); -- 22,21
   --     w7    : no signal because c2 = 0 => w7 = 0
   --     w8    : no signal because two operation realized on the same time
   signal w9_s  : signed((data_size_g +6 -1) downto 0); -- 22,21
   --     w10   : no signal because w4 - w7 = 0 - 0 = 0 => w10 = 0

   signal x1_s  : signed((data_size_g +6 -1) downto 0); -- 22,21
   --     x2    : no signal because w10 = 0 => x2 = 0
   ------------------------------------------------------------------------------

   BEGIN

   ------------------------------------------------------------------------------
   -- Update internal signals
   ------------------------------------------------------------------------------
   update_internal_signals: process(u_i, w1_s, w2_s, w5_s, w6_s, x1_s)
   begin
      w1_s  <= u_i;
--      w2_s  <= w1_s; -- 1 * w1_s
      w2_s  <= shift_right(w1_s, 1); -- 1 * w1_s


-- Farks: To have the same "type" as entry of biquad 2 => 16,14
      w5_s  <= w2_s + resize(shift_right(x1_s, 6), data_size_g);
--      w5_s  <= shift_right(resize(x1_s, data_size_g) + w2_s, 1);
      w6_s  <= resize(w5_s, (data_size_g +6));


      w9_s  <= x1_s - w6_s;

   end process update_internal_signals;
   ------------------------------------------------------------------------------

   ------------------------------------------------------------------------------
   -- Update internal registers
   ------------------------------------------------------------------------------
   update_internal_registers: process(clock_i, reset_i)
   begin
      if reset_i = '1' then
         x1_s <= (others => '0');
      elsif rising_edge(clock_i) then
         if enable_i = '1' then
            x1_s <= w9_s;
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

END ARCHITECTURE simplified;

