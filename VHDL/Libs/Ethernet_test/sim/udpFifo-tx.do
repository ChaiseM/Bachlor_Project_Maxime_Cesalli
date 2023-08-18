onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Fifo
add wave -noupdate -radix ascii /udpfifo_tb/txdata
add wave -noupdate /udpfifo_tb/txfull
add wave -noupdate /udpfifo_tb/txwr
add wave -noupdate -radix ascii /udpfifo_tb/u_4/fifodataout
add wave -noupdate /udpfifo_tb/u_4/fifoempty
add wave -noupdate /udpfifo_tb/u_4/fiforead
add wave -noupdate -divider UDP
add wave -noupdate -radix hexadecimal -subitemconfig {/udpfifo_tb/u_4/udpwriteaddress(9) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(8) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(7) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(6) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(5) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(4) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(3) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(2) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(1) {-radix hexadecimal} /udpfifo_tb/u_4/udpwriteaddress(0) {-radix hexadecimal}} /udpfifo_tb/u_4/udpwriteaddress
add wave -noupdate -radix ascii /udpfifo_tb/u_4/udpwritedata
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/udpwritedata
add wave -noupdate /udpfifo_tb/u_4/sendudpframe
add wave -noupdate /udpfifo_tb/u_4/udpready
add wave -noupdate /udpfifo_tb/u_4/udpwrite
add wave -noupdate /udpfifo_tb/u_4/u_4/packstate
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_4/totallength
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_4/addresscounter
add wave -noupdate /udpfifo_tb/u_4/u_4/checksumcalcen
add wave -noupdate -divider IP
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ipwriteaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ipwritedata
add wave -noupdate /udpfifo_tb/u_4/sendipframe
add wave -noupdate /udpfifo_tb/u_4/ipready
add wave -noupdate /udpfifo_tb/u_4/ipwrite
add wave -noupdate /udpfifo_tb/u_4/u_3/packstate
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_3/addresscounter
add wave -noupdate /udpfifo_tb/u_4/u_3/checksumcalcen
add wave -noupdate -divider Ethernet
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ethaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ethdata
add wave -noupdate /udpfifo_tb/u_4/sendethframe
add wave -noupdate /udpfifo_tb/u_4/ethready
add wave -noupdate /udpfifo_tb/u_4/ethwrite
add wave -noupdate /udpfifo_tb/u_4/u_2/packstate
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_2/baseaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_2/addresscounter
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_2/framelength
add wave -noupdate -divider RAM
add wave -noupdate -radix hexadecimal /udpfifo_tb/tx_baseaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/tx_address
add wave -noupdate -radix hexadecimal /udpfifo_tb/tx_data
add wave -noupdate /udpfifo_tb/tx_write
add wave -noupdate /udpfifo_tb/tx_endofframe
add wave -noupdate -divider MII
add wave -noupdate /udpfifo_tb/mii_txen
add wave -noupdate -radix hexadecimal /udpfifo_tb/mii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3105634 ps} 0}
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
WaveRestoreZoom {0 ps} {5250 ns}
