onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lowpass_tb/reset
add wave -noupdate /lowpass_tb/clock
add wave -noupdate /lowpass_tb/en
add wave -noupdate -format Analog-Step -height 50 -max 2000000000.0 -min -2000000000.0 -radix decimal -radixshowbase 0 /lowpass_tb/audioIn
add wave -noupdate -radix decimal -radixshowbase 0 /lowpass_tb/audioIn
add wave -noupdate -format Analog-Step -height 50 -max 20000000.0 -min -20000000.0 -radix decimal -radixshowbase 0 /lowpass_tb/audioOut
add wave -noupdate -radix decimal -radixshowbase 0 /lowpass_tb/audioOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1050 us}
