ARCHITECTURE ladder OF lowpass IS

-- 6th order Bessel
--
  constant filterOrder : natural := 6;
  constant coefficientBitNb : natural := 8;
  type unsigned_vector_c is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  constant coefficient : unsigned_vector_c := (
    to_unsigned(215, coefficientBitNb),
    to_unsigned( 88, coefficientBitNb),
    to_unsigned( 81, coefficientBitNb),
    to_unsigned( 61, coefficientBitNb),
    to_unsigned( 38, coefficientBitNb),
    to_unsigned( 13, coefficientBitNb)
  );
  constant additionalInternalWBitNb: positive := 5;

  constant internalWBitNb: positive := filterOut'length + additionalInternalWBitNb;
  signal inputSignalScaled : signed(internalWBitNb-1 downto 0);

  constant internalAccumulatorBitNb : positive := internalWBitNb + shiftBitNb;
  type signed_vector_accumulator is array(1 to filterOrder)
    of signed(internalAccumulatorBitNb-1 downto 0);
  type signed_vector_w is array(0 to filterOrder+1)
    of signed(internalWBitNb-1 downto 0);
  signal accumulator : signed_vector_accumulator;
  signal w : signed_vector_w;

  type unsigned_vector_coeffShiftReg is array(1 to filterOrder)
    of unsigned(coefficientBitNb-1 downto 0);
  signal coefficientShiftRegister: unsigned_vector_coeffShiftReg;
  signal multiplicandBit: std_ulogic_vector(1 to filterOrder);
  type signed_vector_multAcc is array(1 to filterOrder)
    of signed(internalAccumulatorBitNb+coefficientBitNb-1 downto 0);
  signal multiplicationAccumulator: signed_vector_multAcc;

  signal cycleCounterShiftReg: unsigned(coefficientBitNb downto 0);
  signal endOfCycle: std_ulogic;
  signal calculating: std_ulogic;

  signal wDebug : signed_vector_w;

BEGIN
  ------------------------------------------------------------------------------
                          -- Scale input signal to internal state variables size
  inputSignalScaled <= SHIFT_LEFT(
    RESIZE(filterIn, inputSignalScaled'length),
    filterOut'length - filterIn'length + 1
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
            RESIZE(w(index+1), accumulator(index)'length)
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
                           -- w(0) combines input and w(1) for first accumulator
    w(0) <= inputSignalScaled - w(1);
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

END ARCHITECTURE ladder;
