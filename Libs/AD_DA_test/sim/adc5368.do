onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Setup
add wave -noupdate /adc5368_tb/clkmode
add wave -noupdate /adc5368_tb/dif0_ad0_cs_n
add wave -noupdate /adc5368_tb/dif1_ad1_cdin
add wave -noupdate /adc5368_tb/m0_sda_cdout
add wave -noupdate /adc5368_tb/m1_scl_cclk
add wave -noupdate /adc5368_tb/mdiv
add wave -noupdate /adc5368_tb/rst_n
add wave -noupdate -divider Clocks
add wave -noupdate /adc5368_tb/lrck_fs
add wave -noupdate /adc5368_tb/mclk
add wave -noupdate /adc5368_tb/sclk
add wave -noupdate -divider {Analog inputs}
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain1
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain2
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain3
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain4
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain5
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain6
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain7
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/ain8
add wave -noupdate -divider {Sampled signals}
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain1_signed
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain2_signed
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain3_signed
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain4_signed
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain5_signed
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain6_signed
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain7_signed
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -min -32000.0 -radix decimal /adc5368_tb/i_adc/ain8_signed
add wave -noupdate -divider {Serial outputs}
add wave -noupdate /adc5368_tb/ovfl_n
add wave -noupdate /adc5368_tb/sdout1_tdm
add wave -noupdate /adc5368_tb/sdout2
add wave -noupdate /adc5368_tb/sdout3_tdm_n
add wave -noupdate /adc5368_tb/sdout4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 201
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
WaveRestoreZoom {0 ps} {1050 us}
