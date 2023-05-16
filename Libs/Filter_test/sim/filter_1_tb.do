onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider System
add wave -noupdate -format Logic /filter_1_tb/sys_clk_o
add wave -noupdate -format Logic /filter_1_tb/sys_rst_o
add wave -noupdate -divider {sample generator}
add wave -noupdate -format Literal /filter_1_tb/i2/time_real_s
add wave -noupdate -format Literal /filter_1_tb/i2/out_amplitude_s
add wave -noupdate -format Literal /filter_1_tb/i2/out_real_s
add wave -noupdate -format Analog-Step -height 74 -offset 32768.0 -radix decimal -scale 0.017048222113979543 /filter_1_tb/i2/out_signed_s
add wave -noupdate -divider {Biquad 1 (input)}
add wave -noupdate -format Logic /filter_1_tb/enable_o
add wave -noupdate -format Analog-Step -height 74 -offset 32768.0 -radix decimal -scale 0.017048222113979543 /filter_1_tb/sample_o
add wave -noupdate -divider {Biquad 1 (input)}
add wave -noupdate -format Logic /filter_1_tb/enable_o
add wave -noupdate -format Analog-Step -height 74 -offset 16353.0 -radix decimal -scale 0.0098439038109970466 /filter_1_tb/sample_s
add wave -noupdate -divider {Filter (output)}
add wave -noupdate -format Logic /filter_1_tb/enable_i
add wave -noupdate -format Analog-Step -height 74 -offset 16353.0 -radix decimal -scale 0.0068863748155435318 /filter_1_tb/sample_i
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {207746 ps} 0}
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
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1155 us}
