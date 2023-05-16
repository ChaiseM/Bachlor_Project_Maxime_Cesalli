onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adc7886controller_tb/reset
add wave -noupdate /adc7886controller_tb/clock
add wave -noupdate -divider Controls
add wave -noupdate /adc7886controller_tb/sClkEn
add wave -noupdate /adc7886controller_tb/startConv
add wave -noupdate -format Analog-Step -height 100 -max 2000.0 -radix unsigned -radixshowbase 0 /adc7886controller_tb/VIN
add wave -noupdate -divider SPI
add wave -noupdate /adc7886controller_tb/CS_n
add wave -noupdate /adc7886controller_tb/SCLK
add wave -noupdate /adc7886controller_tb/SDO
add wave -noupdate -divider Output
add wave -noupdate -format Analog-Step -height 100 -max 2000.0 -radix unsigned -childformat {{/adc7886controller_tb/amplitude(11) -radix unsigned} {/adc7886controller_tb/amplitude(10) -radix unsigned} {/adc7886controller_tb/amplitude(9) -radix unsigned} {/adc7886controller_tb/amplitude(8) -radix unsigned} {/adc7886controller_tb/amplitude(7) -radix unsigned} {/adc7886controller_tb/amplitude(6) -radix unsigned} {/adc7886controller_tb/amplitude(5) -radix unsigned} {/adc7886controller_tb/amplitude(4) -radix unsigned} {/adc7886controller_tb/amplitude(3) -radix unsigned} {/adc7886controller_tb/amplitude(2) -radix unsigned} {/adc7886controller_tb/amplitude(1) -radix unsigned} {/adc7886controller_tb/amplitude(0) -radix unsigned}} -radixshowbase 0 -subitemconfig {/adc7886controller_tb/amplitude(11) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(10) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(9) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(8) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(7) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(6) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(5) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(4) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(3) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(2) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(1) {-height 17 -radix unsigned -radixshowbase 0} /adc7886controller_tb/amplitude(0) {-height 17 -radix unsigned -radixshowbase 0}} /adc7886controller_tb/amplitude
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
configure wave -valuecolwidth 40
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {525 us}
