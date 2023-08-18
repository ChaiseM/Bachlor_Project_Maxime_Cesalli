--
-- VHDL Architecture filters.amplifier_2.behavior
--
-- Created:
--          by - Farquet Sébastien (HES-SO Valais)
--          at - 16:04:48 02.06.2010
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
ARCHITECTURE behavior OF amplifier_2 IS

   ------------------------------------------------------------------------------
   -- Internal signals
   ------------------------------------------------------------------------------
   signal w_s  : signed((data_size_g -1) downto 0);
   ------------------------------------------------------------------------------

BEGIN

   ------------------------------------------------------------------------------
   -- Update internal signals
   ------------------------------------------------------------------------------
   update_internal_signals: process(u_i)
   begin
      if (u_i(u_i'high) /= u_i((u_i'high -1))) then
         w_s           <= (others => u_i(u_i'high -1));
         w_s(w_s'high) <= u_i(u_i'high);
      else
         w_s  <= shift_left(u_i, 1);
      end if;
   end process update_internal_signals;
   ------------------------------------------------------------------------------

   ------------------------------------------------------------------------------
   -- Update output
   ------------------------------------------------------------------------------
   update_output: process(w_s)
   begin
      y_o <= w_s;
   end process update_output;
   ------------------------------------------------------------------------------

END ARCHITECTURE behavior;

