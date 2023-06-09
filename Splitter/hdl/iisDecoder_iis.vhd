--
-- VHDL Architecture Splitter.iisDecoder.iis
--
-- Created:
--          by - maxim.UNKNOWN (DESKTOP-ADLE19A)
--          at - 13:33:57 16/05/2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
LIBRARY gates;
  USE gates.gates.all;
LIBRARY Common;
  USE Common.CommonLib.all;

--
ARCHITECTURE iis OF iisDecoder IS

    signal sck_delayed : std_ulogic;
	signal lrck_delayed : std_ulogic;
	signal sck_rising : std_ulogic;
	signal lrck_changed : std_ulogic;
    signal old_dataValid : std_ulogic;
    signal s_dataValid : std_ulogic;
    
    
	signal bitCounter : unsigned(4 downto 0);  -- count to 32

	signal audioLeftReg  : signed(audioLeft'range);
	signal audioRightReg : signed(audioRight'range);

begin
	delayClocks: process(reset, clock)
	begin
		if reset = '1' then
            
			sck_delayed <= '0';
			lrck_delayed <= '0';
		elsif rising_edge(clock) then
			sck_delayed <= SCK;
			lrck_delayed <= LRCK;
		end if;
	end process delayClocks;

	sck_rising <= '1' when (SCK = '1') and (sck_delayed = '0') else '0';
	lrck_changed <= '1' when lrck_delayed /= LRCK else '0';
    s_dataValid  <= lrck_changed;
    
	countBits: process(reset, clock)
	begin
		if reset = '1' then
			bitCounter <= (others => '0');
		elsif rising_edge(clock) then
        
        
			if lrck_changed = '1' then
				bitCounter <= (others => '0');
			elsif sck_rising = '1' then 
				bitCounter <= bitCounter + 1;
			end if;
		end if;
	end process countBits;

	shiftRegisters: process(reset, clock)
	begin
		if reset = '1' then
            old_dataValid <= '0';
			audioLeftReg  <= (others => '0');
			audioRightReg <= (others => '0');
		elsif rising_edge(clock) then
			if sck_rising = '1' then
				if bitCounter < audioLeftReg'length then
                   
                    
					if LRCK = '0' then    -- odd channel
                        audioLeftReg  <= (others => '0');
						audioLeftReg <= shift_left(audioLeftReg, 1);
                        audioLeftReg(0) <= DOUT;
						
					else -- even channel
                        audioRightReg <= (others => '0');
						audioRightReg <= shift_left(audioRightReg, 1);
                        audioRightReg(0) <= DOUT;
					end if; 
				end if;
			end if;
            
            if s_dataValid = '1' and old_dataValid = '0' then 
                old_dataValid <= '1';
            elsif s_dataValid = '0' and old_dataValid = '1' then 
                old_dataValid <= '0';
            end if ;
            
		end if;
	end process shiftRegisters;

    audioLeft  <= audioLeftReg;
    audioRight <= audioRightReg;

    --s_dataValid  <= '1' when (LRCK = '1') and (bitCounter = audioLeftReg'length+1)
    --else '0';
    
    dataValid <= '1' when s_dataValid = '1' and LRCK = '1'
    else '0';
    
    

END ARCHITECTURE iis;
