--
-- VHDL Architecture filters_test.highpass_50_tester.test_bench
--
-- Created:
--          by - Farquet Sébastien (HES-SO Valais)
--          at - 11:23:18 07.06.2010
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--


library ieee;
   use ieee.math_real.all;

ARCHITECTURE test_bench OF highpass_50_tester IS

--------------------------------------------------------------------------------
-- Clocks
--------------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- System
   --
--   constant sys_frequency_c : real       := 66.0E6;
   constant sys_frequency_c : real       := 10.0* 48.0E3;
   constant sys_period_c    : time       := (1.0/sys_frequency_c) * 1 sec;

   signal sys_clk_s : std_ulogic := '0';
   -----------------------------------------------------------------------------

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Drive communication
--------------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Sytem:
   --
   --   reset signal
   --
   signal waiting_time_s : time       := 0 ns;
   signal during_time_s  : time       := 4*sys_period_c;
   signal reset_pulse_s  : std_ulogic := '0';
   signal sys_rst_s      : std_ulogic := '0';
   -----------------------------------------------------------------------------

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Sample
--------------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Sample
   --
   signal sine_frequency_s : real;
   signal phase_s          : real;
   signal out_amplitude_s  : real;
   signal out_real_s       : real :=  0.0;
   signal out_signed_s     : signed(sample_o'range);
   -----------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Enable
--------------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Enable
   --
   signal enable_s : std_ulogic := '0';
   signal count_s  : unsigned(15 downto 0);
   -----------------------------------------------------------------------------

--------------------------------------------------------------------------------


BEGIN

--------------------------------------------------------------------------------
-- Clocks
--------------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- System
   --
   sys_clk_s <= not sys_clk_s after sys_period_c/2;
   sys_clk_o <= transport sys_clk_s after sys_period_c * 9 / 10;
   -----------------------------------------------------------------------------

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- Drive communication
--------------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Sytem:
   --
   --   reset signal
   --
   sys_reset: process
   begin
      sys_rst_s <= '0';
      wait on reset_pulse_s;
      wait for waiting_time_s;

      sys_rst_s <= '1';
      wait for during_time_s;

   end process sys_reset;

   sys_rst_o <= sys_rst_s;
   -----------------------------------------------------------------------------

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- Sample generator
--------------------------------------------------------------------------------

   real_time: process(sys_clk_s, sys_rst_s)
   begin
      if sys_rst_s = '1' then
         phase_s <= 0.0;
      elsif rising_edge(sys_clk_s) then
         phase_s <= phase_s + sine_frequency_s/sys_frequency_c;
      end if;
   end process real_time;

   out_real_s <= out_amplitude_s * sin(2.0*math_pi*(phase_s));

   out_signed_s <= to_signed(integer(out_real_s * real(2**(out_signed_s'length-1)-1)), out_signed_s'length);

   sample_o <= out_signed_s;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Enable generator
--------------------------------------------------------------------------------

   enable_counter: process(sys_clk_s, sys_rst_s)
   begin
      if sys_rst_s = '1' then
         count_s <= (others => '0');
      elsif rising_edge(sys_clk_s) then
         if count_s < integer(sys_frequency_c/48.0E3) then
            count_s <= count_s +1;
         else
            count_s <= (others => '0');
         end if;
      end if;
   end process enable_counter;

   check_count: process(sys_clk_s, sys_rst_s)
   begin
      if sys_rst_s = '1' then
         enable_s <= '0';
      elsif rising_edge(sys_clk_s) then
         if count_s < integer(sys_frequency_c/48.0E3) then
            enable_s <= '0';
         else
            enable_s <= '1';
         end if;
      end if;
   end process check_count;

   enable_o <= enable_s;

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- Test sequence
--------------------------------------------------------------------------------

   test_sequence: process
   begin

      -- Begin value
      out_amplitude_s <= 1.0;

      wait for 4 ns;
      sine_frequency_s <= 1.0;
	  
      reset_pulse_s  <= '1' after 1 ns, '0' after 2 ns;
      wait for 200 ns;

      for i in 60 downto 1 loop
         sine_frequency_s <= real(i * 5);
         wait for (3.0* (1.0/real(i * 5)) * 1 sec);
      end loop;

      wait;
   end process test_sequence;

--------------------------------------------------------------------------------
END ARCHITECTURE test_bench;

