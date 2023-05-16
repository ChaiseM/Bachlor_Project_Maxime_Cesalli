onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Reset and clock} /lcddemo_tb/reset
add wave -noupdate -expand -group {Reset and clock} /lcddemo_tb/clock
add wave -noupdate -group {Buttons and LEDs} -radix hexadecimal -childformat {{/lcddemo_tb/buttons(1) -radix hexadecimal} {/lcddemo_tb/buttons(2) -radix hexadecimal} {/lcddemo_tb/buttons(3) -radix hexadecimal} {/lcddemo_tb/buttons(4) -radix hexadecimal}} -expand -subitemconfig {/lcddemo_tb/buttons(1) {-height 16 -radix hexadecimal} /lcddemo_tb/buttons(2) {-height 16 -radix hexadecimal} /lcddemo_tb/buttons(3) {-height 16 -radix hexadecimal} /lcddemo_tb/buttons(4) {-height 16 -radix hexadecimal}} /lcddemo_tb/buttons
add wave -noupdate -group {Buttons and LEDs} -radix hexadecimal -childformat {{/lcddemo_tb/leds(1) -radix hexadecimal} {/lcddemo_tb/leds(2) -radix hexadecimal} {/lcddemo_tb/leds(3) -radix hexadecimal} {/lcddemo_tb/leds(4) -radix hexadecimal} {/lcddemo_tb/leds(5) -radix hexadecimal} {/lcddemo_tb/leds(6) -radix hexadecimal} {/lcddemo_tb/leds(7) -radix hexadecimal} {/lcddemo_tb/leds(8) -radix hexadecimal}} -expand -subitemconfig {/lcddemo_tb/leds(1) {-height 16 -radix hexadecimal} /lcddemo_tb/leds(2) {-height 16 -radix hexadecimal} /lcddemo_tb/leds(3) {-height 16 -radix hexadecimal} /lcddemo_tb/leds(4) {-height 16 -radix hexadecimal} /lcddemo_tb/leds(5) {-height 16 -radix hexadecimal} /lcddemo_tb/leds(6) {-height 16 -radix hexadecimal} /lcddemo_tb/leds(7) {-height 16 -radix hexadecimal} /lcddemo_tb/leds(8) {-height 16 -radix hexadecimal}} /lcddemo_tb/leds
add wave -noupdate -expand -group {Hello message} /lcddemo_tb/I_dut/I_hello/buttonRising
add wave -noupdate -expand -group {Hello message} -radix unsigned -radixshowbase 0 /lcddemo_tb/I_dut/I_hello/sequenceCounter
add wave -noupdate -expand -group {Hello message} /lcddemo_tb/I_dut/I_hello/sequenceDone
add wave -noupdate -expand -group {Hello message} /lcddemo_tb/I_dut/helloSend
add wave -noupdate -expand -group {Hello message} -radix hexadecimal -radixshowbase 0 /lcddemo_tb/I_dut/helloData
add wave -noupdate -expand -group {Hello message} -radix ascii -radixshowbase 0 /lcddemo_tb/I_dut/helloData
add wave -noupdate -expand -group {Hello message} /lcddemo_tb/I_dut/helloBusy
add wave -noupdate -expand -group UART /lcddemo_tb/I_tester/rs232OutByte
add wave -noupdate -expand -group UART /lcddemo_tb/I_tester/rs232SendOutByte
add wave -noupdate -expand -group UART /lcddemo_tb/I_dut/RxD
add wave -noupdate -group {LCD controller interface} -radix hexadecimal -radixshowbase 0 /lcddemo_tb/I_dut/ascii
add wave -noupdate -group {LCD controller interface} -radix ascii -radixshowbase 0 /lcddemo_tb/I_dut/ascii
add wave -noupdate -group {LCD controller interface} -radix hexadecimal /lcddemo_tb/I_dut/send
add wave -noupdate -group {LCD controller interface} -radix hexadecimal /lcddemo_tb/I_dut/busy
add wave -noupdate -expand -group {LCD interface} /lcddemo_tb/RST_n
add wave -noupdate -expand -group {LCD interface} /lcddemo_tb/A0
add wave -noupdate -expand -group {LCD interface} /lcddemo_tb/CS1_n
add wave -noupdate -expand -group {LCD interface} /lcddemo_tb/SCL
add wave -noupdate -expand -group {LCD interface} /lcddemo_tb/SI
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 350
configure wave -valuecolwidth 58
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {2527664378 ps}
