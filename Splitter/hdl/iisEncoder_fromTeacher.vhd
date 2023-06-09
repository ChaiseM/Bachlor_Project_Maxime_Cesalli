--
-- VHDL Architecture Splitter.iisEncoder.fromTeacher
--
-- Created:
--          by - maxime.cesalli.UNKNOWN (WE2330804)
--          at - 15:03:31 07.06.2023
--
-- using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
--
ARCHITECTURE fromTeacher OF iisEncoder IS

   type State_t is (State_Reset, State_LoadWord, State_TransmitWord);
    signal CurrentState     : State_t                                       := State_Reset;
    signal Tx_Int           : STD_LOGIC_VECTOR(((2 * DATA_DATA_WIDTH) - 1) downto 0)  := (others => '0');
    signal Ready_Int        : STD_LOGIC                                     := '0';
    signal LRCLK_Int        : STD_LOGIC                                     := '1';
    signal SD_Int           : STD_LOGIC                                     := '0';
    signal Enable           : STD_LOGIC                                     := '0';
begin
    process
        variable BitCounter : INTEGER := 0;
    begin
        wait until falling_edge(Clock);
        case CurrentState is
            when State_Reset =>
                Ready_Int <= '0';
                LRCLK_Int <= '1';
                Enable <= '1';
                SD_Int <= '0';
                Tx_Int <= (others => '0');
                CurrentState <= State_LoadWord;
            when State_LoadWord =>
                BitCounter := 0;
                Tx_Int <= Tx;
                LRCLK_Int <= '0';
                CurrentState <= State_TransmitWord;
            when State_TransmitWord =>
                BitCounter := BitCounter + 1;
                if(BitCounter > (DATA_WIDTH - 1)) then
                    LRCLK_Int <= '1';
                end if;
                if(BitCounter < ((2 * DATA_WIDTH) - 1)) then
                    Ready_Int <= '0';
                    CurrentState <= State_TransmitWord;
                else
                    Ready_Int <= '1';
                    CurrentState <= State_LoadWord;
                end if;
                Tx_Int <= Tx_Int(((2 * DATA_WIDTH) - 2) downto 0) & "0";
                SD_Int <= Tx_Int((2 * DATA_WIDTH) - 1);
        end case;
        if(nReset = '0') then
            CurrentState <= State_Reset;        
        end if;
    end process;
    Ready <= Ready_Int;
    SCLK <= Clock and Enable;
    LRCLK <= LRCLK_Int;
    SD <= SD_Int;
END ARCHITECTURE fromTeacher;

