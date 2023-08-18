# Script to replay the last simulation run
cd $SCRATCH_DIR/$DESIGN_NAME/Lcd_test/work
"C:\eda\Modelsim/win32/vsim" -f hds_args.tmp
