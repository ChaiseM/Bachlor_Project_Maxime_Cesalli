------------------------------------
-- temporary block to test the RAM
------------------------------------
ARCHITECTURE HighLevel OF HighLevel IS
BEGIN
    writeEnA <= '1'; 
    writeENB <= '0';
    dataInB <= "0000000000000000";
END ARCHITECTURE HighLevel;

