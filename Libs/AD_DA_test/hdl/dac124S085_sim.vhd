ARCHITECTURE sim OF dac124S085 IS
                                                                  -- DAC control
  constant opWriteReg          : natural := 0;
  constant opWriteAndUpdate    : natural := 1;
  constant opWriteAllAndUpdate : natural := 2;
  constant opPowerDown         : natural := 3;
  signal dacId, opId : natural;
  type amplitudeType is array(1 to dacNb) of natural;
  signal amplitude : amplitudeType;
  signal shiftRegister: unsigned(15 downto 0);
  signal dataValid : boolean;

BEGIN
                                                              -- read input data
  shiftBits: process
  begin
    dataValid <= false;
    wait until falling_edge(SYNC_n);
    for index in shiftRegister'range loop
      wait until falling_edge(SCLK);
      shiftRegister <= shift_left(shiftRegister, 1);
      shiftRegister(0) <= DIN;
    end loop;
    wait for 0 ns;
    dataValid <= true;
    wait for 1 ns;
  end process shiftBits;
                                                             -- update registers
  updateRegisters: process
  begin
    wait until dataValid;
    dacId <= to_integer(
      shiftRegister(shiftRegister'high downto shiftRegister'high-1)
    );
    opId <= to_integer(
      shiftRegister(shiftRegister'high-2 downto shiftRegister'high-3)
    );
    wait for 0 ns;
    if (opId = opWriteReg) or (opId = opWriteAndUpdate) then
      amplitude(dacId+1) <= to_integer(shiftRegister(dacBitNb-1 downto 0));
    end if;
  end process updateRegisters;
                                                               -- update outputs
  updateOutputs: process
  begin
    wait until dataValid;
    wait for 1 ns;
    if opId = opWriteAndUpdate then
      case dacId is
        when 0 => VOUTA <= amplitude(dacId+1);
        when 1 => VOUTB <= amplitude(dacId+1);
        when 2 => VOUTC <= amplitude(dacId+1);
        when 3 => VOUTD <= amplitude(dacId+1);
        when others => null;
      end case;
    end if;
  end process updateOutputs;

END ARCHITECTURE sim;
