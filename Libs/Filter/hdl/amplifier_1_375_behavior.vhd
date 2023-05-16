--
-- VHDL Architecture filters.amplifier_1_375.behavior
--
-- Created:
--          by - Farquet Sébastien (HES-SO Valais)
--          at - 15:32:43 02.06.2010
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
ARCHITECTURE behavior OF amplifier_1_375 IS

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
      w_s  <= u_i + shift_right(u_i, 2) + shift_right(u_i, 3);
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

