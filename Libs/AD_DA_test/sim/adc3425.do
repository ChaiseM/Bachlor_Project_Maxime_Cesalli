onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {I2C control}
add wave -noupdate /adc3425_tb/i_tb/i2cwritedata
add wave -noupdate /adc3425_tb/i_tb/i2cwrite
add wave -noupdate /adc3425_tb/i_tb/i2cread
add wave -noupdate /adc3425_tb/i_tb/i2cready
add wave -noupdate -divider {I2C Bus}
add wave -noupdate /adc3425_tb/scl
add wave -noupdate /adc3425_tb/sda
add wave -noupdate -divider {I2C command decoding}
add wave -noupdate /adc3425_tb/i_dut/isselected
add wave -noupdate /adc3425_tb/i_dut/currentstate
add wave -noupdate /adc3425_tb/i_dut/i2cdata
add wave -noupdate /adc3425_tb/i_dut/endofword
add wave -noupdate -divider Registers
add wave -noupdate /adc3425_tb/i_dut/configurationreg
add wave -noupdate -divider {I2C answering}
add wave -noupdate -radix unsigned /adc3425_tb/i_dut/bitcounter
add wave -noupdate /adc3425_tb/i_dut/sendackmoment
add wave -noupdate /adc3425_tb/i_dut/sendack
add wave -noupdate -radix hexadecimal /adc3425_tb/i_dut/signalsample
add wave -noupdate /adc3425_tb/i_dut/signalsample
add wave -noupdate /adc3425_tb/i_dut/databyteid
add wave -noupdate /adc3425_tb/i_dut/datashiftregister
add wave -noupdate -radix hexadecimal /adc3425_tb/i_tb/i2creaddata
add wave -noupdate -radix hexadecimal /adc3425_tb/i_tb/i2csignalsample
add wave -noupdate -divider Voltages
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -radix unsigned /adc3425_tb/vinm
add wave -noupdate -format Analog-Step -height 30 -max 32000.0 -radix unsigned /adc3425_tb/vinp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 300
configure wave -valuecolwidth 45
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
WaveRestoreZoom {0 ps} {78750 ns}
