onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {MII - Rx}
add wave -noupdate /udpfifo_tb/u_2/frameinfo
add wave -noupdate /udpfifo_tb/mii_rxdv
add wave -noupdate -radix hexadecimal /udpfifo_tb/mii_rxd
add wave -noupdate -divider {RAM - Rx}
add wave -noupdate -radix hexadecimal /udpfifo_tb/rx_baseaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/rx_address
add wave -noupdate -radix hexadecimal /udpfifo_tb/rx_data
add wave -noupdate /udpfifo_tb/rx_startofframe
add wave -noupdate -divider {Ethernet - Rx}
add wave -noupdate /udpfifo_tb/u_4/u_0/startofframe
add wave -noupdate /udpfifo_tb/u_4/u_0/unpackstate
add wave -noupdate -radix hexadecimal -subitemconfig {/udpfifo_tb/u_4/sourcemacaddr(47) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(46) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(45) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(44) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(43) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(42) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(41) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(40) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(39) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(38) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(37) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(36) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(35) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(34) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(33) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(32) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(31) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(30) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(29) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(28) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(27) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(26) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(25) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(24) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(23) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(22) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(21) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(20) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(19) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(18) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(17) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(16) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(15) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(14) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(13) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(12) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(11) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(10) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(9) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(8) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(7) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(6) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(5) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(4) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(3) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(2) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(1) {-radix hexadecimal} /udpfifo_tb/u_4/sourcemacaddr(0) {-radix hexadecimal}} /udpfifo_tb/u_4/sourcemacaddr
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ethertype
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ethreadaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ethreaddata
add wave -noupdate /udpfifo_tb/u_4/newethinframe
add wave -noupdate /udpfifo_tb/u_4/ethdone
add wave -noupdate -divider {IP - Rx}
add wave -noupdate /udpfifo_tb/u_4/u_1/unpackstate
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ippayloadlength
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/sourceipaddr
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ipdata
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/ipreadaddress
add wave -noupdate /udpfifo_tb/u_4/newipframe
add wave -noupdate /udpfifo_tb/u_4/ipdone
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_1/addresscounter
add wave -noupdate /udpfifo_tb/u_4/u_1/udpchecksumcalcen
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_1/headerdata16
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_1/udpchecksum
add wave -noupdate -divider {UDP - Rx}
add wave -noupdate /udpfifo_tb/u_4/u_8/unpackstate
add wave -noupdate /udpfifo_tb/u_4/u_8/checksumcalcen
add wave -noupdate -radix hexadecimal -subitemconfig {/udpfifo_tb/u_4/udppseudoheaderchecksum(16) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(15) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(14) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(13) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(12) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(11) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(10) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(9) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(8) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(7) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(6) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(5) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(4) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(3) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(2) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(1) {-radix hexadecimal} /udpfifo_tb/u_4/udppseudoheaderchecksum(0) {-radix hexadecimal}} /udpfifo_tb/u_4/udppseudoheaderchecksum
add wave -noupdate /udpfifo_tb/u_4/u_8/readheaderend
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_8/addresscounter
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_8/headerdata16
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_8/checksum
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/u_8/checksuminv
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/sourceudpport
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/udppayloadlength
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/udpreadaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/u_4/udpreaddata
add wave -noupdate /udpfifo_tb/u_4/newudpframe
add wave -noupdate /udpfifo_tb/u_4/udpdone
add wave -noupdate -divider {Fifo - Rx}
add wave -noupdate -radix ascii /udpfifo_tb/u_4/fifodatain
add wave -noupdate /udpfifo_tb/u_4/fifofull
add wave -noupdate /udpfifo_tb/u_4/fifowrite
add wave -noupdate -radix ascii /udpfifo_tb/rxdata
add wave -noupdate /udpfifo_tb/rxempty
add wave -noupdate /udpfifo_tb/rxrd
add wave -noupdate /udpfifo_tb/u_1/fifoinstring
add wave -noupdate /udpfifo_tb/udpchecksumerror
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {39794331 ps} 0}
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
WaveRestoreZoom {0 ps} {52500 ns}
