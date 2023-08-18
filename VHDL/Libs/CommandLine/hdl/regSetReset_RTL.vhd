LIBRARY Common;
  USE Common.commonLib.all;

ARCHITECTURE RTL OF regSetReset IS

  signal bitSelector : unsigned(requiredBitNb(regValues'length)-1 downto 0);

BEGIN
  ------------------------------------------------------------------------------
                                                             -- set or reset bit
  bitSelector <= resize(id, bitSelector'length);

  updateBit: process(reset, clock)
  begin
    if reset = '1' then
      regValues <= (others => '0');
    elsif rising_edge(clock) then
      if en = '1' then
        regValues(to_integer(bitSelector)) <= newValue;
      end if;
    end if;
  end process updateBit;

END ARCHITECTURE RTL;
