onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {MII - Rx}
add wave -noupdate /udpfifo_tb/miitx0/frameinfo
add wave -noupdate /udpfifo_tb/mii_rxdv
add wave -noupdate -radix hexadecimal /udpfifo_tb/mii_rxd
add wave -noupdate -divider {RAM - Rx}
add wave -noupdate -radix unsigned /udpfifo_tb/rx_baseaddress
add wave -noupdate -radix unsigned /udpfifo_tb/rx_address
add wave -noupdate -radix hexadecimal /udpfifo_tb/rx_data
add wave -noupdate /udpfifo_tb/rx_startofframe
add wave -noupdate -divider {Ethernet - Rx}
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/startofframe
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/unpackstate
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/sourcemacaddr
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/ethertype
add wave -noupdate -radix unsigned /udpfifo_tb/udpfifo0/ethreadaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/ethreaddata
add wave -noupdate /udpfifo_tb/udpfifo0/newethinframe
add wave -noupdate /udpfifo_tb/udpfifo0/ethdone
add wave -noupdate -divider {IP - Rx}
add wave -noupdate /udpfifo_tb/udpfifo0/u_ipu/unpackstate
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/ippayloadlength
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/sourceipaddr
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/ipdata
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/ipreadaddress
add wave -noupdate /udpfifo_tb/udpfifo0/newipframe
add wave -noupdate /udpfifo_tb/udpfifo0/ipdone
add wave -noupdate /udpfifo_tb/isbroadcast
add wave -noupdate /udpfifo_tb/ismulticast
add wave -noupdate -divider {UDP - Rx}
add wave -noupdate /udpfifo_tb/udpfifo0/u_udpu/unpackstate
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/sourceudpport
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpportin
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/udppayloadlength
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/udpreadaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/udpreaddata
add wave -noupdate /udpfifo_tb/udpfifo0/newudpframe
add wave -noupdate /udpfifo_tb/udpfifo0/udpdone
add wave -noupdate -divider {Fifo - Rx}
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/fifodatain
add wave -noupdate /udpfifo_tb/udpfifo0/fifofull
add wave -noupdate /udpfifo_tb/udpfifo0/fifowrite
add wave -noupdate -radix ascii /udpfifo_tb/rxdata
add wave -noupdate /udpfifo_tb/rxempty
add wave -noupdate /udpfifo_tb/rxrd
add wave -noupdate -divider {Fifo - Tx}
add wave -noupdate -radix ascii /udpfifo_tb/txdata
add wave -noupdate /udpfifo_tb/txfull
add wave -noupdate /udpfifo_tb/txwr
add wave -noupdate -divider {UDP - Tx}
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpportout
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/udpwriteaddress
add wave -noupdate -radix ascii /udpfifo_tb/udpfifo0/udpwritedata
add wave -noupdate /udpfifo_tb/udpfifo0/sendudpframe
add wave -noupdate /udpfifo_tb/udpfifo0/udpready
add wave -noupdate /udpfifo_tb/udpfifo0/udpwrite
add wave -noupdate /udpfifo_tb/udpfifo0/u_udpp/packstate
add wave -noupdate -divider {IP - Tx}
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/ipwriteaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/ipwritedata
add wave -noupdate /udpfifo_tb/udpfifo0/sendipframe
add wave -noupdate /udpfifo_tb/udpfifo0/ipready
add wave -noupdate /udpfifo_tb/udpfifo0/ipwrite
add wave -noupdate /udpfifo_tb/udpfifo0/u_ipp/packstate
add wave -noupdate -divider {Ethernet - Tx}
add wave -noupdate /udpfifo_tb/udpfifo0/ethready
add wave -noupdate /udpfifo_tb/udpfifo0/ethwrite
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethp/packstate
add wave -noupdate -divider {RAM - Tx}
add wave -noupdate -radix unsigned /udpfifo_tb/tx_baseaddress
add wave -noupdate -radix unsigned /udpfifo_tb/tx_address
add wave -noupdate -radix hexadecimal /udpfifo_tb/tx_data
add wave -noupdate /udpfifo_tb/tx_write
add wave -noupdate /udpfifo_tb/tx_endofframe
add wave -noupdate -divider {MII - Tx}
add wave -noupdate /udpfifo_tb/mii_txen
add wave -noupdate -radix hexadecimal /udpfifo_tb/mii_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/macaddressbitnb
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/ethertypebitnb
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/ramaddressbitnb
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/ramdatabitnb
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/fifodatabitnb
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/clock
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/u_ethu/destmacaddr
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/done
add wave -noupdate -radix unsigned -subitemconfig {/udpfifo_tb/udpfifo0/u_ethu/ethaddress(9) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(8) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(7) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(6) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(5) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(4) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(3) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(2) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(1) {-radix unsigned} /udpfifo_tb/udpfifo0/u_ethu/ethaddress(0) {-radix unsigned}} /udpfifo_tb/udpfifo0/u_ethu/ethaddress
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/reset
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/rx_startofframe
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/u_ethu/datashiftregister
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/u_ethu/rx_data
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/u_ethu/ethdata
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/u_ethu/ethertype
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/isbroadcast
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/ismulticast
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/newframe
add wave -noupdate -radix unsigned /udpfifo_tb/udpfifo0/u_ethu/payloadlength
add wave -noupdate -radix unsigned /udpfifo_tb/udpfifo0/u_ethu/rx_address
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/rx_baseaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/u_ethu/sourcemacaddr
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/unpackstate
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/startofframe
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/baseaddress
add wave -noupdate -radix unsigned /udpfifo_tb/udpfifo0/u_ethu/addresscounter
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/addressstep
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/addresslsb
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpfifo0/u_ethu/datau
add wave -noupdate -radix unsigned /udpfifo_tb/udpfifo0/u_ethu/framelength
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/isbroadcastint
add wave -noupdate /udpfifo_tb/udpfifo0/u_ethu/ismulticastint
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1600000 ps} 1} {{Cursor 2} {7243979 ps} 0}
configure wave -namecolwidth 272
configure wave -valuecolwidth 73
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {6806511 ps} {7303955 ps}
