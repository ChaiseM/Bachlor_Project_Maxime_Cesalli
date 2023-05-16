# Script to replay the last simulation run
cd $SCRATCH_DIR/$DESIGN_NAME/Lcd_test/work
"C:\eda\modeltech_6.6e/win32/vsim" -f hds_args.tmp
