--------------------------------------------------------------------------------
-- multiplexor to switch between the modified data and the raw
--------------------------------------------------------------------------------
ARCHITECTURE TIOrFPGA OF muxOut IS
BEGIN
    Data_O <= DOUT when S20 = '0' else Data_I ;
    LR_O <= LRCK when S20 = '0' else LR_I ;
    CLK_O <= SCK when S20 = '0' else CLK_I ;
END ARCHITECTURE TIOrFPGA;

