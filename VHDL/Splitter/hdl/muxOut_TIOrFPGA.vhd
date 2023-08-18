--------------------------------------------------------------------------------
-- multiplexor to switch between the modified data and the raw
--------------------------------------------------------------------------------
ARCHITECTURE TIOrFPGA OF muxOut IS
BEGIN
    Data_O <= DOUT when en = '0' else '0' ;
    LR_O <= LRCK when en = '0' else '0' ;
    CLK_O <= SCK when en = '0' else '0' ;
END ARCHITECTURE TIOrFPGA;

