# filename:          py_eth_packet_generation
# kind:              python file
# first created:     21.03.2012
# created by:        zas
#-------------------------------------------------------------------------------
# History:
# v0.1 : zas 21.03.2012 -- Initial Version
#-------------------------------------------------------------------------------
# Description: 
# Generates Ethernet Frames for the MII Transmitter in the Ethernet_tb Library
# randomize = 0 => generates nbr_of_frames starting from min length and always +1
# randomize = 1 => random data, random_length (between min and max), nbr_of_frames
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Import
#
import random
import math

#-------------------------------------------------------------------------------
# Constant
#
filename      = 'udp_RealWorldTest.eth'
nbr_of_frames = 10000
min_length    = 10
max_length    = 1518
randomize      = True
en_frame_error = True
en_valid_error = True
en_crc_error   = True
verbose        = False
error_type     = 0

max_packet_size = 1518
crc_length    = 4
header_key   = 'at      '
header_value = '1 us'
info_key     = 'info    '
info_value   = 'Bytes Packet'
data_key0    = 'error   '
data_value_1 = 'RX_ERR'
data_value_2 = 'RX_DV'
data_key1    = 'frame   '
data_key2    = '        '
data_value   = ''
footer_key   = 'wait    '
footer_value = '8 us'
crc_key      = 'crc     '
eol          = '\n'

# packet time all in us
sfd_time  = 0.64  # Starf of Frame Delimiter (5D)
ifg_time  = 0.96  # Interframe Gap
byte_time = 0.08  # time to send onme byte

# Open File in write mode
f = file(filename, 'w')

# Write start parameter
line = header_key + header_value + eol + eol
f.write(line)

# Frame number loop
for frame_nbr in range(0, nbr_of_frames):
  if verbose:
    print 'frame_nbr ' + str(frame_nbr)

  # Set frame length
  if randomize:
    frame_length = random.randint(min_length,max_length)
  else:
    if frame_nbr == 0:
      frame_length = min_length 
    else:
      frame_length = frame_length + 1
   
  # Write Frame info
  line = info_key + str(frame_length) + ' ' + info_value + eol
  f.write(line)

  # see if error should occure (always random)
  error_type = random.randint(0,3)
  if en_frame_error and error_type == 1:
    line = data_key0 + data_value_1 + eol
    # Write data line
    f.write(line)
    if verbose:
      print "packet with frame error"
  elif en_valid_error and error_type == 2:
    line = data_key0 + data_value_2 + eol
    # Write data line
    f.write(line)
    if verbose:
      print "packet with valid error"

  if verbose:
    print 'frame_length ' + str(frame_length)
  # Byte loop
  for byte in range(0, frame_length-crc_length, 16):
    data_value = ''
    if verbose:
      print 'byte ' + str(byte)
    # Generate data for line
    for byteline in range(byte, byte+16):
      if verbose:
        print 'byteline ' + str(byteline)
      if randomize:
        hex_str = "%0.2X" % (random.randint(0, 256)%256)
      else:
        # Generate 2 digit 
        hex_str = "%0.2X" % (byteline%256)
      if byteline < frame_length-crc_length and byteline < max_packet_size-crc_length:
        if verbose:
          print 'write data ' + hex_str
        data_value = data_value + hex_str + ' '
        
    # Check if first line
    if byte == 0:
      line = data_key1 + data_value + eol
    else:
      line = data_key2 + data_value + eol
    
    # Write data line
    f.write(line)
  
  # Write CRC if a false CRC is needed
  if en_crc_error and error_type == 3:
    if verbose:
      print "packet with crc error"
    hex_str = ""
    # Generate FALSE CRC
    for byte in range(0,4):
      hex_str = hex_str + "%0.2X" % (random.randint(0, 256)%256)
    if verbose:
      print 'crc data ' + hex_str
    line = crc_key + hex_str + eol
    # Write data line
    f.write(line)
  # Write wait after frame
  # Calculate time to send frame
  frame_time = int(math.ceil(ifg_time + sfd_time + ((frame_length)*byte_time)))
  line = footer_key + str(frame_time) + " us" + eol + eol
  f.write(line)
  
# Close file
f.close()
  

