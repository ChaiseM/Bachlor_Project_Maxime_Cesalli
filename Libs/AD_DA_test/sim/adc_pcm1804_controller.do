onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adc_pcm1804_controller_tb/reset
add wave -noupdate /adc_pcm1804_controller_tb/clock
add wave -noupdate -divider Controls
add wave -noupdate /adc_pcm1804_controller_tb/ad_rst_n
add wave -noupdate /adc_pcm1804_controller_tb/ad_bypas
add wave -noupdate /adc_pcm1804_controller_tb/ad_fmt
add wave -noupdate /adc_pcm1804_controller_tb/OVFR
add wave -noupdate /adc_pcm1804_controller_tb/S_M
add wave -noupdate /adc_pcm1804_controller_tb/ad_osr
add wave -noupdate -divider {Analog inputs}
add wave -noupdate /adc_pcm1804_controller_tb/VINLp
add wave -noupdate /adc_pcm1804_controller_tb/VINLm
add wave -noupdate /adc_pcm1804_controller_tb/VINRp
add wave -noupdate /adc_pcm1804_controller_tb/VINRm
add wave -noupdate -divider Clocks
add wave -noupdate /adc_pcm1804_controller_tb/ad_scki
add wave -noupdate /adc_pcm1804_controller_tb/ad_bck
add wave -noupdate /adc_pcm1804_controller_tb/ad_lrck
add wave -noupdate -divider {Serial Output}
add wave -noupdate /adc_pcm1804_controller_tb/ad_data
add wave -noupdate -divider {Parallel Output}
add wave -noupdate /adc_pcm1804_controller_tb/data_en
add wave -noupdate /adc_pcm1804_controller_tb/l_channel
add wave -noupdate -format Analog-Step -height 74 -max 4192058.0 -min -4192058.0 /adc_pcm1804_controller_tb/l_channel
add wave -noupdate /adc_pcm1804_controller_tb/r_channel
add wave -noupdate -divider {PCM1804 ctrl}
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/ad_system_clock
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/rst_n_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/reset_cnt
add wave -noupdate -format Analog-Step -height 74 -max 131071.00000000001 -min -131072.0 -radix unsigned /adc_pcm1804_controller_tb/PCM1804_ctrl/reset_cnt
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/data_valid_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/reset_cnt_enable
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/lrck_delayed
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/lrck_changed
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/bck_delayed_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/bck_rising_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/bit_cnt_l
add wave -noupdate -format Analog-Step -height 74 -max 32.0 -radix unsigned /adc_pcm1804_controller_tb/PCM1804_ctrl/bit_cnt_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/bit_cnt_enable_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/bit_cnt_reset_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/l_channel_data_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/l_channel_out_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/r_channel_data_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/r_channel_out_l
add wave -noupdate /adc_pcm1804_controller_tb/PCM1804_ctrl/data_en_l
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20481567 ps} 0} {{Cursor 2} {11886178828 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 189
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {11655883979 ps} {12123408070 ps}
