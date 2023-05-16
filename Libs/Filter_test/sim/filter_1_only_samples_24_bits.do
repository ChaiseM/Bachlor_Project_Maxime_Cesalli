onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {sample generator}
add wave -noupdate -format Literal -radix decimal /filter_1_tb/i2/sine_frequency_s
add wave -noupdate -format Analog-Step -height 200 -offset 8388608.0 -radix decimal -scale 1.1682510375976563e-005 /filter_1_tb/i2/out_signed_s
add wave -noupdate -divider {Biquad 1 (input)}
add wave -noupdate -format Logic /filter_1_tb/enable_o
add wave -noupdate -format Analog-Step -height 200 -offset 8388608.0 -radix decimal -scale 1.1682510375976563e-005 /filter_1_tb/sample_o
add wave -noupdate -divider {Biquad 2 (input)}
add wave -noupdate -format Logic /filter_1_tb/enable_o
add wave -noupdate -format Analog-Step -height 200 -offset 8388608.0 -radix decimal -scale 1.1682510375976563e-005 /filter_1_tb/sample_out_biquad_1_s
add wave -noupdate -divider {Amplifier (input)}
add wave -noupdate -format Analog-Step -height 200 -offset 8388608.0 -radix decimal -scale 1.1682510375976563e-005 /filter_1_tb/sample_out_biquad_2_s
add wave -noupdate -format Literal -radix decimal /filter_1_tb/i2/sine_frequency_s
add wave -noupdate -divider {Filter (output)}
add wave -noupdate -format Logic /filter_1_tb/enable_i
add wave -noupdate -format Analog-Step -height 200 -offset 8388608.0 -radix decimal -scale 1.1682510375976563e-005 /filter_1_tb/sample_i
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {930015029790 ps} 0} {{Cursor 2} {165950935458 ps} 0}
configure wave -namecolwidth 230
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
configure wave -timeline 1
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {1890 ms}
