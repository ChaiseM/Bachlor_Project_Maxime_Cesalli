onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lcddemo_tb/reset
add wave -noupdate /lcddemo_tb/clock
add wave -noupdate -divider Controls
add wave -noupdate -radix hexadecimal /lcddemo_tb/leds
add wave -noupdate -radix hexadecimal /lcddemo_tb/buttons
add wave -noupdate -divider UART
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/dataout
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/datavalid
add wave -noupdate -divider Test
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/send_int
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/busy_int
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/ascii_int
add wave -noupdate -divider {ASCII data}
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/ascii
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/send
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/busy
add wave -noupdate -divider Encoder
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/asciisend
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/asciibusy
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/asciidata
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/asciibitnb
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/lcdcolumnnb
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/lcddatabitnb
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/lcdpagenb
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/fontrownb
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/fontcolumnnb
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/fontdisplaystate
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/asciicolumncounter
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/columncounter
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/pagecounter
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_font/pixeloffset
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/pixeldata
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/a0
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/cleardisplay
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/lcdsend
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/lcdbusy
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/i_font/lcddata
add wave -noupdate -divider Initialization
add wave -noupdate /lcddemo_tb/i_dut/i_lcd/i_init/cleardisplay
add wave -noupdate /lcddemo_tb/i_dut/i_lcd/i_init/initsequencedone
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_init/initsequencecounter
add wave -noupdate /lcddemo_tb/i_dut/i_lcd/i_init/clearsequencedone
add wave -noupdate -radix unsigned /lcddemo_tb/i_dut/i_lcd/i_init/clearsequencecounter
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/lcdsend
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/lcdbusy
add wave -noupdate -radix hexadecimal /lcddemo_tb/i_dut/i_lcd/lcddata
add wave -noupdate -divider LCD
add wave -noupdate /lcddemo_tb/rst_n
add wave -noupdate /lcddemo_tb/a0
add wave -noupdate /lcddemo_tb/cs1_n
add wave -noupdate /lcddemo_tb/scl
add wave -noupdate /lcddemo_tb/si
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 350
configure wave -valuecolwidth 58
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
WaveRestoreZoom {0 ps} {31265344 ps}
