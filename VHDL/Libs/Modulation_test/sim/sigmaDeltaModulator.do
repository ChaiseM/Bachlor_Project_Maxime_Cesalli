onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sigmadeltamodulator_tb/reset
add wave -noupdate /sigmadeltamodulator_tb/clock
add wave -noupdate -divider Input
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal /sigmadeltamodulator_tb/parallelin
add wave -noupdate -divider Modulator
add wave -noupdate /sigmadeltamodulator_tb/serialout
add wave -noupdate -divider {Filtered output}
add wave -noupdate -format Analog-Step -height 50 -max 16000.0 -min -16000.0 -radix decimal /sigmadeltamodulator_tb/filterout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 220
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {21 us}
