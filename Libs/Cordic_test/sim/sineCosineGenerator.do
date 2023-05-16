onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sinecosinegenerator_tb/clock
add wave -noupdate /sinecosinegenerator_tb/reset
add wave -noupdate -divider {Amplitude and phase control}
add wave -noupdate -format Analog-Step -height 50 -max 65000.0 -radix unsigned -radixshowbase 0 /sinecosinegenerator_tb/amplitude
add wave -noupdate -format Analog-Step -height 50 -max 65000.0 -radix unsigned -radixshowbase 0 /sinecosinegenerator_tb/step
add wave -noupdate -format Analog-Step -height 50 -max 1000000.0 -radix unsigned -radixshowbase 0 /sinecosinegenerator_tb/I_DUT/sawtooth
add wave -noupdate -divider {Sine and cosine}
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /sinecosinegenerator_tb/cosine
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /sinecosinegenerator_tb/sine
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {381483645 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {32550 us}
