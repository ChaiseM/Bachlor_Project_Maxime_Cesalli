ARCHITECTURE cidf OF sigmaDeltaModulator IS
-- Cascaded Integrators with Distributed Feedback

-- 2nd order Bessel
--
  constant filterOrder : natural := 2;
  constant coefficientBitNb : natural := 6;
  type unsigned_vector_c is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  constant coefficient : unsigned_vector_c := (
    to_unsigned( 7, coefficientBitNb),
    to_unsigned(25, coefficientBitNb)
  );
  constant additionalInternalWBitNb: positive := 4;

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
--  constant additionalInternalWBitNb: positive := 5;

  constant internalWBitNb: positive := parallelIn'length + additionalInternalWBitNb;
  signal inputSignalScaled : signed(internalWBitNb-1 downto 0);
                                                              -- state variables
  constant internalAccumulatorBitNb : positive := internalWBitNb + shiftBitNb;
  type signed_vector_accumulator is array(1 to filterOrder)
    of signed(internalAccumulatorBitNb-1 downto 0);
  type signed_vector_w is array(0 to filterOrder+1)
    of signed(internalWBitNb-1 downto 0);
  signal accumulator : signed_vector_accumulator;
  signal w : signed_vector_w;
                                                                 -- quantization
  constant maxAmplitude: signed(internalWBitNb-1 downto 0) :=
    shift_left(to_signed(1, internalWBitNb), parallelIn'length-1);
  signal quantized : std_ulogic;

BEGIN
  ------------------------------------------------------------------------------
                          -- Scale input signal to internal state variables size
  inputSignalScaled <= RESIZE(parallelIn, inputSignalScaled'length);

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

  process(accumulator, w, inputSignalScaled, quantized)
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
                    -- w(filterOrder+1) is the quantized value of w(filterOrder)
    if quantized = '1' then
      w(filterOrder+1) <= maxAmplitude;
    else
      w(filterOrder+1) <= -maxAmplitude;
    end if;
  end process;

  quantized <= '1' when w(filterOrder) >= 0
    else '0';

  ------------------------------------------------------------------------------
                                    -- Scale last state variables to output size
    serialOut <= quantized;

END cidf;

