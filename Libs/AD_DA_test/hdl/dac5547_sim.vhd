library Common;
  use Common.CommonLib.all;

ARCHITECTURE RTL OF dac5547 IS

  subtype dacRegisterType is unsigned(D'range);
  type dacRegisterArrayType is array(1 to A'length) of dacRegisterType;
  signal inputRegisters, outputlatches: dacRegisterArrayType;

  signal A_int: unsigned(A'range);

BEGIN

  invertLSB: process(A)
  begin
    A_int <= A;
    A_int(0) <= not A(0);
  end process invertLSB;

  ------------------------------------------------------------------------------
                                                              -- input registers
  registerInputs: process(RS_n, WR_n, A_int, D)
  begin
    if RS_n = not '1' then
      inputRegisters <= (others => (others => '0'));
      if MSB = '1' then
        for index in inputRegisters'range loop
          inputRegisters(index)(dacRegisterType'high) <= '1';
        end loop;
      end if;
    elsif WR_n = '0' then
      for index in inputRegisters'range loop
        if A_int(index-1) = '1' then
          inputRegisters(index) <= D;
        end if;
      end loop;
    end if;
  end process registerInputs;

  ------------------------------------------------------------------------------
                                                               -- output latches
  latchAmplitudes: process(RS_n, LDAC, inputRegisters)
  begin
    if RS_n = not '1' then
      outputlatches <= (others => (others => '0'));
      if MSB = '1' then
        for index in inputRegisters'range loop
          outputlatches(index)(dacRegisterType'high) <= '1';
        end loop;
      end if;
    elsif LDAC = '1' then
      outputlatches <= inputRegisters;
    end if;
  end process latchAmplitudes;

  ------------------------------------------------------------------------------
                                                                      -- outputs
  OUTA <= to_integer(outputlatches(1));
  OUTB <= to_integer(outputlatches(2));

END ARCHITECTURE RTL;
