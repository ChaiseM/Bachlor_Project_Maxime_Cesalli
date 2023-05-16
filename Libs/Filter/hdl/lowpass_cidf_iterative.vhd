ARCHITECTURE cidf_iterative OF lowpass IS
-- Cascaded Integrators with Distributed Feedback

-- 16th order Bessel
--
  constant filterOrder : natural := 16;
  constant coefficientBitNb : natural := 13;
  type unsigned_vector_c is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  constant coefficient : unsigned_vector_c := (
    to_unsigned(  28, coefficientBitNb),
    to_unsigned(  58, coefficientBitNb),
    to_unsigned(  90, coefficientBitNb),
    to_unsigned( 125, coefficientBitNb),
    to_unsigned( 164, coefficientBitNb),
    to_unsigned( 208, coefficientBitNb),
    to_unsigned( 258, coefficientBitNb),
    to_unsigned( 316, coefficientBitNb),
    to_unsigned( 386, coefficientBitNb),
    to_unsigned( 472, coefficientBitNb),
    to_unsigned( 583, coefficientBitNb),
    to_unsigned( 733, coefficientBitNb),
    to_unsigned( 953, coefficientBitNb),
    to_unsigned(1310, coefficientBitNb),
    to_unsigned(2014, coefficientBitNb),
    to_unsigned(4104, coefficientBitNb)
  );
  constant additionalInternalWBitNb: positive := 10;

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
                                 -- coefficients and multiplication accumulators
  type unsigned_vector_coeffShiftReg is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  signal coefficientShiftRegister: unsigned_vector_coeffShiftReg;
  signal multiplicandBit: std_ulogic_vector(1 to filterOrder);
  type signed_vector_multAcc is array(1 to filterOrder)
    of signed(internalAccumulatorBitNb+coefficientBitNb-1 downto 0);
  signal multiplicationAccumulator: signed_vector_multAcc;
                                              -- multiplication sequence counter
  signal cycleCounterShiftReg: unsigned(coefficientBitNb downto 0);
  signal endOfCycle: std_ulogic;
  signal calculating: std_ulogic;
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
                                                      -- Multiplication sequence

                                                            -- Coefficient shift
  shiftCoefficientBits: process(reset, clock)
  begin
    if reset = '1' then
      coefficientShiftregister <= (others => (others => '0'));
    elsif rising_edge(clock) then
      for index in 1 to filterOrder loop
        if en = '1' then
          coefficientShiftregister(index) <= coefficient(index);
        else
          coefficientShiftregister(index) <=
            shift_right(coefficientShiftregister(index), 1);
        end if;
      end loop;
    end if;
  end process shiftCoefficientBits;

  selectMultiplicantBit: process(coefficientShiftregister)
  begin
    for index in 1 to filterOrder loop
      multiplicandBit(index) <= coefficientShiftregister(index)(0);
    end loop;
  end process selectMultiplicantBit;

                                                 -- Multiplication accumulator
  accumulateForMultiplication: process(reset, clock)
  begin
    if reset = '1' then
      multiplicationAccumulator <= (others => (others => '0'));
    elsif rising_edge(clock) then
      for index in 1 to filterOrder loop
                                                 -- Start a new multiplication
        if en = '1' then
          multiplicationAccumulator(index) <= (others => '0');
        elsif calculating = '1' then
                                                     -- Bit is '0': shift by 1
          if multiplicandBit(index) = '0' then
            multiplicationAccumulator(index) <=
              shift_right(multiplicationAccumulator(index), 1);
                                             -- Bit is '1': shift by 1 and add
          else
            multiplicationAccumulator(index) <=
              shift_right(multiplicationAccumulator(index), 1) +
              shift_left(
                resize(accumulator(index), multiplicationAccumulator(index)'length),
                coefficientBitNb
              );
          end if;
        end if;
      end loop;
    end if;
  end process accumulateForMultiplication;

  ------------------------------------------------------------------------------
                                                -- Analog filter state variables
  process(multiplicationAccumulator, w, inputSignalScaled)
  begin
    for index in 1 to filterOrder loop
      w(index) <= RESIZE(
        SHIFT_RIGHT(
          multiplicationAccumulator(index),
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
                          -- Scale last state variables to output size and latch
  storeResult: process(reset, clock)
  begin
    if reset = '1' then
      filterOut <= (others => '0');
    elsif rising_edge(clock) then
      if calculating = '0' then
        filterOut <= RESIZE(w(w'high), filterOut'length);
      end if;
    end if;
  end process storeResult;

  ------------------------------------------------------------------------------
                                                 -- Multiplication cycle counter
  countBits: process(reset, clock)
  begin
    if reset = '1' then
      cycleCounterShiftReg <= (others => '0');
    elsif rising_edge(clock) then
      cycleCounterShiftReg <= shift_right(cycleCounterShiftReg, 1);
      cycleCounterShiftReg(cycleCounterShiftReg'high) <= en;
    end if;
  end process countBits;

  endOfCycle <= cycleCounterShiftReg(0);
  calculating <= '1' when cycleCounterShiftReg /= 0
    else '0';

  ------------------------------------------------------------------------------
                                           -- signals sampled after calculations
                                                     -- for amplitude estimation
  process(reset, clock)
  begin
    if reset = '1' then
      wDebug <= (others => (others => '0'));
    elsif rising_edge(clock) then
      if calculating = '0' then
        wDebug <= w;
      end if;
    end if;
  end process;

END ARCHITECTURE cidf_iterative;
