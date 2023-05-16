--------------------------------------------------------------------------------
ARCHITECTURE butterworth3 OF lowpass IS

  constant filterOrder : natural := 3;
  type natural_vector_t is array(1 to filterOrder) of natural;
  constant t : natural_vector_t := (0, 1, 0);

  constant additionalinternalWBitNb: positive := 2;
  constant internalWBitNb: positive := filterOut'length + additionalinternalWBitNb;
  signal inputSignalScaled : signed(internalWBitNb-1 downto 0);

  constant internalaccumulatorBitNb : positive := internalWBitNb + shiftBitNb;
  type signed_vector_accumulator is array(1 to filterOrder)
    of signed(internalaccumulatorBitNb-1 downto 0);
  type signed_vector_w is array(0 to filterOrder+1)
    of signed(internalWBitNb-1 downto 0);
  signal accumulator : signed_vector_accumulator;
  signal w : signed_vector_w;

BEGIN
  ------------------------------------------------------------------------------
                          -- Scale input signal to internal state variables size
  inputSignalScaled <= SHIFT_LEFT(
    RESIZE(filterIn, inputSignalScaled'length),
    filterOut'length - filterIn'length
  );

  ------------------------------------------------------------------------------
                                                            -- Accumulator chain
  process(reset, clock)
  begin
    if reset = '1' then
      accumulator <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if en = '1' then
        for index in 1 to filterOrder loop
          accumulator(index) <= accumulator(index) + (
            RESIZE(w(index-1), accumulator(index)'length) -
            RESIZE(w(index+1), accumulator(index)'length)
          );
        end loop;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
                                                -- Analog filter state variables
  process(accumulator, w, inputSignalScaled)
  begin
    for index in 1 to filterOrder loop
      w(index) <= RESIZE(
        SHIFT_RIGHT(
          accumulator(index),
          t(index) + shiftBitNb
        ),
        w(index)'length
      );
    end loop;
                           -- w(0) combines input and w(1) for first accumulator
    w(0) <= inputSignalScaled - w(1);
            -- w(filterOrder+1) is a copy of w(filterOrder) for last accumulator
    w(filterOrder+1) <= w(filterOrder);
  end process;

  ------------------------------------------------------------------------------
                                    -- Scale last state variables to output size
  filterOut <= RESIZE(w(w'high), filterOut'length);

END butterworth3;
