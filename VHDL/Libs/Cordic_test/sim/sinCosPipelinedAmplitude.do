onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sincospipelinedamplitude_tb/clock
add wave -noupdate /sincospipelinedamplitude_tb/reset
add wave -noupdate -divider {Amplitude and phase}
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /sincospipelinedamplitude_tb/amplitude
add wave -noupdate -format Analog-Step -height 50 -max 65000.0 -radix unsigned -radixshowbase 0 /sincospipelinedamplitude_tb/phase
add wave -noupdate -divider {Sine and Cosine}
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /sincospipelinedamplitude_tb/sine
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /sincospipelinedamplitude_tb/cosine
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 224
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
WaveRestoreZoom {0 ps} {15750 us}
