onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {MII - Rx}
add wave -noupdate /udpfifo_tb/u_2/frameinfo
add wave -noupdate /udpfifo_tb/mii_rxdv
add wave -noupdate -radix hexadecimal /udpfifo_tb/mii_rxd
add wave -noupdate -divider {Ethernet - Rx}
add wave -noupdate -radix hexadecimal /udpfifo_tb/macaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/sourcemacaddr
add wave -noupdate -radix hexadecimal /udpfifo_tb/ipaddress
add wave -noupdate -radix hexadecimal /udpfifo_tb/sourceipaddr
add wave -noupdate /udpfifo_tb/isbroadcast
add wave -noupdate /udpfifo_tb/ismulticast
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpportin
add wave -noupdate -radix hexadecimal /udpfifo_tb/sourceudpport
add wave -noupdate /udpfifo_tb/udpchecksumerror
add wave -noupdate -divider {Fifo - Rx}
add wave -noupdate -radix ascii -subitemconfig {/udpfifo_tb/rxdata(7) {-radix ascii} /udpfifo_tb/rxdata(6) {-radix ascii} /udpfifo_tb/rxdata(5) {-radix ascii} /udpfifo_tb/rxdata(4) {-radix ascii} /udpfifo_tb/rxdata(3) {-radix ascii} /udpfifo_tb/rxdata(2) {-radix ascii} /udpfifo_tb/rxdata(1) {-radix ascii} /udpfifo_tb/rxdata(0) {-radix ascii}} /udpfifo_tb/rxdata
add wave -noupdate /udpfifo_tb/rxrd
add wave -noupdate -divider Application
add wave -noupdate /udpfifo_tb/u_5/udpdatavalid
add wave -noupdate /udpfifo_tb/u_5/rxselectedinstance
add wave -noupdate /udpfifo_tb/rxempty
add wave -noupdate /udpfifo_tb/u_5/readen
add wave -noupdate /udpfifo_tb/u_5/writerequest
add wave -noupdate /udpfifo_tb/u_5/txselectedinstance
add wave -noupdate -divider {Fifo - Tx}
add wave -noupdate -radix ascii /udpfifo_tb/txdata
add wave -noupdate /udpfifo_tb/txfull
add wave -noupdate /udpfifo_tb/txwr
add wave -noupdate -divider {Ethernet - Tx}
add wave -noupdate -radix hexadecimal /udpfifo_tb/udpportout
add wave -noupdate -radix hexadecimal /udpfifo_tb/destudpport
add wave -noupdate -radix hexadecimal /udpfifo_tb/destipaddr
add wave -noupdate -radix hexadecimal /udpfifo_tb/destmacaddr
add wave -noupdate -divider {MII - Tx}
add wave -noupdate /udpfifo_tb/mii_txen
add wave -noupdate -radix hexadecimal /udpfifo_tb/mii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17643405 ps} 0}
configure wave -namecolwidth 253
configure wave -valuecolwidth 85
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
WaveRestoreZoom {0 ps} {37800 ns}
