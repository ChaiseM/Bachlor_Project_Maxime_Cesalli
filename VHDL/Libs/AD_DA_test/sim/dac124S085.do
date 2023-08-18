onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 100 -max 4095.0 -radix unsigned -radixshowbase 0 /dac124s085_tb/I_TB/signalInteger
add wave -noupdate /dac124s085_tb/SYNC_n
add wave -noupdate /dac124s085_tb/SCLK
add wave -noupdate /dac124s085_tb/DIN
add wave -noupdate -format Analog-Step -height 50 -max 4095.0 -radix unsigned -radixshowbase 0 /dac124s085_tb/VOUTA
add wave -noupdate -format Analog-Step -height 50 -max 4095.0 -radix unsigned -radixshowbase 0 /dac124s085_tb/VOUTB
add wave -noupdate -format Analog-Step -height 50 -max 4095.0 -radix unsigned -radixshowbase 0 /dac124s085_tb/VOUTC
add wave -noupdate -format Analog-Step -height 50 -max 4095.0 -radix unsigned -radixshowbase 0 /dac124s085_tb/VOUTD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {58242413 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {1155 us}
