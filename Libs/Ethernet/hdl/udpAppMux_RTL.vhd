ARCHITECTURE RTL OF udpAppMux IS
BEGIN

  selectData: process(
    select1,
    destMacAddress1, destMacAddress2,
    destIpAddress1 , destIpAddress2,
    udpPortOut1    , udpPortOut2,
    destUdpPort1   , destUdpPort2,
    txWr1          , txWr2,
    txData1        , txData2
  )
  begin
    if select1 = '1' then
      destMacAddress <= destMacAddress1;
      destIpAddress  <= destIpAddress1;
      udpPortOut     <= udpPortOut1;
      destUdpPort    <= destUdpPort1;
      txWr           <= txWr1;
      txData         <= txData1;
    else
      destMacAddress <= destMacAddress2;
      destIpAddress  <= destIpAddress2;
      udpPortOut     <= udpPortOut2;
      destUdpPort    <= destUdpPort2;
      txWr           <= txWr2;
      txData         <= txData2;
    end if;
  end process selectData;

END ARCHITECTURE RTL;
