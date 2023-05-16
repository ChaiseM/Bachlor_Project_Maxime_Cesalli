ARCHITECTURE cidf OF lowpass IS
-- Cascaded Integrators with Distributed Feedback

-- 2nd order Bessel
--
--  constant filterOrder : natural := 2;
--  constant coefficientBitNb : natural := 6;
--  type unsigned_vector_c is array(1 to filterOrder)
--    of unsigned(coefficientBitNb-1 downto 0);
--  constant coefficient : unsigned_vector_c := (
--    to_unsigned( 7, coefficientBitNb),
--    to_unsigned(25, coefficientBitNb)
--  );
--  constant additionalInternalWBitNb: positive := 4;

-- 3rd order Bessel
--
--  constant filterOrder : natural := 3;
--  constant coefficientBitNb : natural := 7;
--  type unsigned_vector_c is array(1 to filterOrder)
--    of unsigned(coefficientBitNb-1 downto 0);
--  constant coefficient : unsigned_vector_c := (
--    to_unsigned(11, coefficientBitNb),
--    to_unsigned(30, coefficientBitNb),
--    to_unsigned(81, coefficientBitNb)
--  );
--  constant additionalInternalWBitNb: positive := 4;

-- 16th order Bessel
--
--  constant filterOrder : natural := 16;
--  constant coefficientBitNb : natural := 13;
--  type unsigned_vector_c is array(1 to filterOrder)
--    of unsigned(coefficientBitNb-1 downto 0);
--  constant coefficient : unsigned_vector_c := (
--    to_unsigned(  28, coefficientBitNb),
--    to_unsigned(  58, coefficientBitNb),
--    to_unsigned(  90, coefficientBitNb),
--    to_unsigned( 125, coefficientBitNb),
--    to_unsigned( 164, coefficientBitNb),
--    to_unsigned( 208, coefficientBitNb),
--    to_unsigned( 258, coefficientBitNb),
--    to_unsigned( 316, coefficientBitNb),
--    to_unsigned( 386, coefficientBitNb),
--    to_unsigned( 472, coefficientBitNb),
--    to_unsigned( 583, coefficientBitNb),
--    to_unsigned( 733, coefficientBitNb),
--    to_unsigned( 953, coefficientBitNb),
--    to_unsigned(1310, coefficientBitNb),
--    to_unsigned(2014, coefficientBitNb),
--    to_unsigned(4104, coefficientBitNb)
--  );
--  constant additionalInternalWBitNb: positive := 10;

-- 8th order Legendre transfer functon
--
  constant filterOrder : natural := 8;
  constant coefficientBitNb : natural := 16;
  type unsigned_vector_c is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  constant coefficient : unsigned_vector_c := (
    to_unsigned(388, coefficientBitNb),
    to_unsigned(781, coefficientBitNb),
    to_unsigned(1212, coefficientBitNb),
    to_unsigned(1666, coefficientBitNb),
    to_unsigned(2325, coefficientBitNb),
    to_unsigned(2932, coefficientBitNb),
    to_unsigned(4732, coefficientBitNb),
    to_unsigned(5481, coefficientBitNb)
  );
  constant additionalInternalWBitNb: positive := 8;

  constant internalWBitNb: positive := filterOut'length + additionalInternalWBitNb;
  signal inputSignalScaled : signed(internalWBitNb-1 downto 0);
                                                              -- state variables
  constant internalAccumulatorBitNb : positive := internalWBitNb + shiftBitNb;
  type signed_vector_accumulator is array(1 to filterOrder)
    of signed(internalAccumulatorBitNb-1 downto 0);
  type signed_vector_w is array(0 to filterOrder+1)
    of signed(internalWBitNb-1 downto 0);
  signal accumulator : signed_vector_accumulator;
  signal w : signed_vector_w;
                                                     -- for amplitude estimation
  signal wDebug : signed_vector_w;

BEGIN
  ------------------------------------------------------------------------------
                          -- Scale input signal to internal state variables size
  inputSignalScaled <= SHIFT_LEFT(
    RESIZE(filterIn, inputSignalScaled'length),
    filterOut'length - filterIn'length
  );

  ------------------------------------------------------------------------------
                                                            -- Accumulator chain
  filterStructure: process(reset, clock)
  begin
    if reset = '1' then
      accumulator <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if en = '1' then
        for index in 1 to filterOrder loop
          accumulator(index) <= accumulator(index) + (
            RESIZE(w(index-1), accumulator(index)'length) -
            RESIZE(w(filterOrder+1), accumulator(index)'length)
          );
        end loop;
      end if;
    end if;
  end process filterStructure;

  ------------------------------------------------------------------------------
                                                -- Analog filter state variables
  process(accumulator, w, inputSignalScaled)
  begin
    for index in 1 to filterOrder loop
      w(index) <= RESIZE(
        SHIFT_RIGHT(
          accumulator(index) * signed('0' & coefficient(index)),
          coefficientBitNb + shiftBitNb
        ),
        w(index)'length
      );
    end loop;
                                                      -- w(0) takes input signal
    w(0) <= inputSignalScaled;
            -- w(filterOrder+1) is a copy of w(filterOrder) for last accumulator
    w(filterOrder+1) <= w(filterOrder);
  end process;

  ------------------------------------------------------------------------------
                                    -- Scale last state variables to output size
    filterOut <= RESIZE(w(w'high), filterOut'length);

  ------------------------------------------------------------------------------
                                                     -- for amplitude estimation
  wDebug <= w;

END ARCHITECTURE cidf;
