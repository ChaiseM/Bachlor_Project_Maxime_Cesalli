-----------------------------------------------------------------------------
-- multiplexing the acces to the RAM between the coeff writer and the Xover 
-----------------------------------------------------------------------------

ARCHITECTURE Coeffs OF RAMmultiplexer IS
BEGIN

    writeEnB1 <= writeEnB when enB = '1' else re;
    addressB1 <= addressB when enB = '1' else rdaddr;
    enB1 <= '1';


END ARCHITECTURE Coeffs;

