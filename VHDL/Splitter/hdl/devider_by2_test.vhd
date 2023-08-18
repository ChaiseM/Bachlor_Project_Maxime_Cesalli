-- devides audioFull by 2
ARCHITECTURE by2_test OF devider IS
    
BEGIN

        audioDevided <= resize((shift_right(audiofull,1)),audioDevided'length);

END ARCHITECTURE by2_test;

