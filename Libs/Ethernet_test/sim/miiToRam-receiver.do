onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {MII - Rx}
add wave -noupdate /miitoram_tb/u_0/i0/rx_reset
add wave -noupdate /miitoram_tb/mii_crs
add wave -noupdate /miitoram_tb/u_2/frameinfo
add wave -noupdate /miitoram_tb/mii_rxdv
add wave -noupdate -radix hexadecimal /miitoram_tb/mii_rxd
add wave -noupdate /miitoram_tb/mii_rxer
add wave -noupdate -divider Receiver
add wave -noupdate /miitoram_tb/u_0/i0/i1/current_state
add wave -noupdate /miitoram_tb/u_0/i0/initframe
add wave -noupdate /miitoram_tb/u_0/i0/startofframe_int
add wave -noupdate /miitoram_tb/u_0/i0/frameok
add wave -noupdate /miitoram_tb/u_0/i0/frameerror
add wave -noupdate -format Analog-Step -height 40 -max 256.0 -radix unsigned /miitoram_tb/u_0/i0/ramwriteaddress
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i0/miibyte
add wave -noupdate /miitoram_tb/u_0/i0/miibyteen
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i0/i2/writeaddress_int
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i0/i2/baseaddress
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i0/framelength
add wave -noupdate /miitoram_tb/u_0/i0/errorcode
add wave -noupdate /miitoram_tb/u_0/i0/ramwrite
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i0/ramwriteaddress
add wave -noupdate -radix hexadecimal -subitemconfig {/miitoram_tb/u_0/i0/ramwritedata(15) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(14) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(13) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(12) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(11) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(10) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(9) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(8) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(7) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(6) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(5) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(4) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(3) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(2) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(1) {-radix hexadecimal} /miitoram_tb/u_0/i0/ramwritedata(0) {-radix hexadecimal}} /miitoram_tb/u_0/i0/ramwritedata
add wave -noupdate -divider CRC
add wave -noupdate /miitoram_tb/u_0/i0/crcinit
add wave -noupdate /miitoram_tb/u_0/i0/crccalculate
add wave -noupdate /miitoram_tb/u_0/i0/crcok
add wave -noupdate -divider {RAM - Rx}
add wave -noupdate /miitoram_tb/reset
add wave -noupdate /miitoram_tb/clock
add wave -noupdate /miitoram_tb/rx_startofframe
add wave -noupdate /miitoram_tb/u_1/read_frames
add wave -noupdate -radix hexadecimal /miitoram_tb/rx_baseaddress
add wave -noupdate -radix hexadecimal /miitoram_tb/rx_address
add wave -noupdate -radix hexadecimal /miitoram_tb/rx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14168526 ps} 0}
configure wave -namecolwidth 232
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
WaveRestoreZoom {0 ps} {10500 ns}
