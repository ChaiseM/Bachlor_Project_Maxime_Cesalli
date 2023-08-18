library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF helloWorld IS

  constant displaySequenceLength: positive := 97;
  type displayDataType is array (1 to displaySequenceLength+1)
    of natural;
  constant displayData: displayDataType :=(
    character'pos(can), -- cancel (clear display)
    character'pos(stx), -- start of text (pos 0,0)
    character'pos('H'), -- Line 1
    character'pos('E'),
    character'pos('S'),
    character'pos('-'),
    character'pos('S'),
    character'pos('O'),
    character'pos('/'),
    character'pos('/'),
    character'pos('V'),
    character'pos('a'),
    character'pos('l'),
    character'pos('a'),
    character'pos('i'),
    character'pos('s'),
    character'pos(' '),
    character'pos('W'),
    character'pos('a'),
    character'pos('l'),
    character'pos('l'),
    character'pos('i'),
    character'pos('s'),
    character'pos(' '),
    character'pos(cr),
    character'pos(lf),
    character'pos('-'), -- Line 2
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos('-'),
    character'pos(cr),
    character'pos(lf),
    character'pos('F'), -- Line 3
    character'pos('P'),
    character'pos('G'),
    character'pos('A'),
    character'pos('-'),
    character'pos('E'),
    character'pos('B'),
    character'pos('S'),
    character'pos(' '),
    character'pos('L'),
    character'pos('C'),
    character'pos('D'),
    character'pos('-'),
    character'pos('E'),
    character'pos('x'),
    character'pos('t'),
    character'pos('e'),
    character'pos('n'),
    character'pos('s'),
    character'pos('i'),
    character'pos('o'),
    character'pos('n'),
    character'pos(cr),
    character'pos(lf),
    character'pos('L'), -- Line 4
    character'pos('C'),
    character'pos('D'),
    character'pos(','),
    character'pos(' '),
    character'pos('4'),
    character'pos(' '),
    character'pos('B'),
    character'pos('u'),
    character'pos('t'),
    character'pos('t'),
    character'pos('o'),
    character'pos('n'),
    character'pos('s'),
    character'pos(','),
    character'pos(' '),
    character'pos('8'),
    character'pos(' '),
    character'pos('L'),
    character'pos('e'),
    character'pos('d'),
    character'pos('s'),
    character'pos(stx),  -- start of text (pos 0,0)
    character'pos('-')
  );

  signal sequenceCounter: unsigned(requiredBitNb(displaySequenceLength+1)-1 downto 0);
  signal sequenceDone: std_ulogic;

  signal buttonDelayed, buttonRising: std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                                                             -- find button push
  delayButton: process(reset, clock) 
	begin
    if reset='1' then
			buttonDelayed <= '0';
    elsif rising_edge(clock) then
      buttonDelayed <= button;
    end if;
  end process delayButton;

  buttonRising <= '1' when (button = '1') and (buttonDelayed = '0')
    else '0';

  ------------------------------------------------------------------------------
                                                     -- display sequence counter
  countDisplaySequence: process(reset, clock) 
	begin
    if reset='1' then
			sequenceCounter <= to_unsigned(1, sequenceCounter'length);
    elsif rising_edge(clock) then
      if (buttonRising = '1') and (sequenceDone = '1') then
  			sequenceCounter <= to_unsigned(1, sequenceCounter'length);
      elsif busy = '0' then
        if sequenceDone = '0' then
          sequenceCounter <= sequenceCounter + 1;
        end if;
      end if;
    end if;
  end process countDisplaySequence;

  sequenceDone <= '1' when sequenceCounter > displaySequenceLength
    else '0';

  ------------------------------------------------------------------------------
                                                               -- output control
	ascii <= std_ulogic_vector(to_unsigned(
    displayData(to_integer(sequenceCounter)), ascii'length
  )) when (sequenceCounter > 0)
    else (others => '-');
	send <= not busy when sequenceDone = '0'
	  else '0';

END ARCHITECTURE RTL;
