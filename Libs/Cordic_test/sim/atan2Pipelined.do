onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /atan2pipelined_tb/clock
add wave -noupdate /atan2pipelined_tb/reset
add wave -noupdate -divider {Sine and cosine}
add wave -noupdate -format Analog-Step -height 100 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /atan2pipelined_tb/cosine
add wave -noupdate -format Analog-Step -height 100 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /atan2pipelined_tb/sine
add wave -noupdate -divider {Arc tangent}
add wave -noupdate -format Analog-Step -height 100 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /atan2pipelined_tb/phase
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 227
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
WaveRestoreZoom {0 ps} {2100 us}
