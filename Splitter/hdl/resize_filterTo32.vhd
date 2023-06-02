--
--
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;
    ARCHITECTURE filterTo32 OF resize IS

    constant SHIFT_NUMBER : integer := audioInn'length-audioOutt'length;
    --signal audioVector : std_ulogic_vector(audioInn'range);

BEGIN
    
    --audioOutt <= resize(audioInn, audioOutt'length);

END ARCHITECTURE filterTo32;

