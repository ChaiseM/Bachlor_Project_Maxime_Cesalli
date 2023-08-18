#! /usr/bin/python
import sys
import os
import math
                                                                   # definitions
command_bit_nb = 8
command_length = 20  # together with parameter
commands = [
    'version',
    'sampling',
    'relays',
    "memRead",
    "memWrite"
]
indent = '  '
                                                              # choose file name
rom_filespec = sys.argv[0]
(base_file_spec, extension) = os.path.splitext(rom_filespec)
rom_filespec = base_file_spec + '.txt'
print 'Writing commands to ' + rom_filespec
                                                            # write file content
rom_line_format = "{0:0"+"{0:d}".format(command_bit_nb)+"b}"
rom_file = open(rom_filespec, 'w')
for command in commands:
	sys.stdout.write(indent)
	for index in range(command_length):
		if index < len(command):
			character = command[index]
		elif index == len(command):
			if index == 0:
				character = chr(2**command_bit_nb-1)
			else:
				character = '\r'
		else:
			character = chr(0)
		sys.stdout.write(character)
		rom_file.write(rom_line_format.format(ord(character)))
		rom_file.write("\n")
	sys.stdout.write("\n")
                                                                      # pad file
line_nb = command_length * len(commands)
print "Wrote {} lines".format(line_nb)
rom_address_bit_nb = int(math.ceil(math.log(line_nb, 2)))
file_line_nb = 2**rom_address_bit_nb
print indent + "Padding to {} lines ({} address bits)"\
	.format(file_line_nb, rom_address_bit_nb)
for index in range(file_line_nb - line_nb):
	rom_file.write(rom_line_format.format(2**command_bit_nb-1))
	rom_file.write("\n")
rom_file.close()
                                                              # display generics
print ''
print 'Generic parameters:'
print indent + "commandNb = {}".format(len(commands))
print indent + "commandLength = {}".format(command_length)
