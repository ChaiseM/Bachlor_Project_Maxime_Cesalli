onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adc5368_controller_tb/clock
add wave -noupdate /adc5368_controller_tb/reset
add wave -noupdate -divider Setup
add wave -noupdate /adc5368_controller_tb/init
add wave -noupdate /adc5368_controller_tb/rst_n
add wave -noupdate /adc5368_controller_tb/clkmode
add wave -noupdate /adc5368_controller_tb/dif0
add wave -noupdate /adc5368_controller_tb/dif1
add wave -noupdate /adc5368_controller_tb/m0
add wave -noupdate /adc5368_controller_tb/m1
add wave -noupdate /adc5368_controller_tb/mdiv
add wave -noupdate -divider {Analog inputs}
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain1
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain2
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain3
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain4
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain5
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain6
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain7
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/ain8
add wave -noupdate -divider Clocks
add wave -noupdate /adc5368_controller_tb/mclk
add wave -noupdate /adc5368_controller_tb/sclk
add wave -noupdate /adc5368_controller_tb/lrck_fs
add wave -noupdate -divider {Serial outputs}
add wave -noupdate /adc5368_controller_tb/ovfl_n
add wave -noupdate /adc5368_controller_tb/sdout1
add wave -noupdate /adc5368_controller_tb/sdout2
add wave -noupdate /adc5368_controller_tb/sdout3
add wave -noupdate /adc5368_controller_tb/sdout4
add wave -noupdate -divider {Digitized signals}
add wave -noupdate /adc5368_controller_tb/sampleen
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample1
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample2
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample3
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample4
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample5
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample6
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample7
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /adc5368_controller_tb/sample8
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 231
configure wave -valuecolwidth 100
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {2100 us}
