import tkinter as tk
from tkinter import filedialog
import os
import time
import serial
from tkinter import ttk
from tkinter import messagebox
from tqdm import tqdm

progress_bar = None
error_label = None
file_not_found_label = None


def show_file_not_found_message(file_name):
    global file_not_found_label
    if file_not_found_label:
        file_not_found_label.destroy()  # Remove previous error label if exists

    message = f"Error: File '{file_name}' not found."
    file_not_found_label = tk.Label(root, text=message, fg='red')
    file_not_found_label.grid(row=8, column=0, columnspan=3, padx=10, pady=5)


def show_error_message(message):
    global error_label
    if error_label:
        error_label.destroy()  # Remove previous error label if exists

    error_label = tk.Label(root, text=message, fg='red')
    error_label.grid(row=7, column=0, columnspan=3, padx=10, pady=5)


def update_progress_bar(current_value, total_value):
    progress_bar['value'] = (current_value / total_value) * 100
    root.update_idletasks()  # Update the GUI


def browse_file_1():
    file_path = filedialog.askopenfilename()
    file_1_entry.delete(0, tk.END)
    file_1_entry.insert(0, file_path)


def browse_file_2():
    file_path = filedialog.askopenfilename()
    file_2_entry.delete(0, tk.END)
    file_2_entry.insert(0, file_path)


def float_to_twos_complement_hex(f):
    int_rep = int(f * (2 ** 31))
    int_rep &= 0xFFFFFFFF
    hex_rep = format(int_rep, '08X')
    return hex_rep


def send_gain():
    selected_gain = gain_var.get()
    selected_com_port = com_var.get()

    if selected_gain < 1 or selected_gain > 15:
        log_message("Invalid gain value. Please select a value between 1 and 15.")
        return

    gain_hex = format(selected_gain, '04X')
    gain_command = f"G{gain_hex}T "

    try:
        ser = serial.Serial(selected_com_port, baudrate=9600, bytesize=serial.SEVENBITS, parity=serial.PARITY_NONE,
                            stopbits=serial.STOPBITS_ONE)
    except serial.SerialException:
        show_error_message("Error: Unable to open serial port. Check the COM port.")
        return

    for char in gain_command:
        ser.write(char.encode())
        # time.sleep(0.001)  # 100us delay between characters

    ser.close()
    # Remove the error label
    global error_label
    if error_label:
        error_label.destroy()

    log_message(f"Gain value {selected_gain} sent through RS232.")
    log_message(f" RS232 DATA is {gain_command} .")


def process_files():
    file_path_1 = file_1_entry.get()
    file_path_2 = file_2_entry.get()

    # Check if the files exist
    if not os.path.exists(file_path_1):
        show_file_not_found_message(os.path.basename(file_path_1))
        return
    if not os.path.exists(file_path_2):
        show_file_not_found_message(os.path.basename(file_path_2))
        return

    # Read and process file 1
    with open(file_path_1, 'r') as file1:
        float_values_1 = [float(line.strip()) for line in file1]

    # Read and process file 2
    with open(file_path_2, 'r') as file2:
        float_values_2 = [float(line.strip()) for line in file2]

    # Combine the two lists of values alternately
    combined_values = [val for pair in zip(float_values_1, float_values_2) for val in pair]

    # Find the point of symmetry and keep values above it
    symmetry_point = len(combined_values) // 2
    values_above_symmetry = combined_values[:symmetry_point]

    # Get the directory of the input files
    input_dir = os.path.dirname(file_path_1)

    # Write the values above the symmetry point to a new file in the same directory
    output_file_path = os.path.join(input_dir, "values_above_symmetry.txt")
    with open(output_file_path, 'w') as output_file:
        # Write "NEW" followed by the number of values - 1 in hexadecimal format (4 symbols) and then "T"
        num_values_hex = format(len(values_above_symmetry) - 1, '04X')
        output_file.write(f"NEW{num_values_hex}T\n")

        # Write each value surrounded by "x!" and "!"
        for value in values_above_symmetry:
            hex_value = float_to_twos_complement_hex(value)
            output_file.write(f"x!{hex_value}!\n")

    log_message(f"Values above symmetry point written to: {output_file_path}")

    # Send the contents of the output file through RS232 (COM1)
    send_rs232(output_file_path)


def create_hex_file():
    file_path_1 = file_1_entry.get()
    file_path_2 = file_2_entry.get()
    # Check if the files exist
    if not os.path.exists(file_path_1):
        show_file_not_found_message(os.path.basename(file_path_1))
        return
    if not os.path.exists(file_path_2):
        show_file_not_found_message(os.path.basename(file_path_2))
        return

    # Read and process file 1
    with open(file_path_1, 'r') as file1:
        float_values_1 = [float(line.strip()) for line in file1]

    # Read and process file 2
    with open(file_path_2, 'r') as file2:
        float_values_2 = [float(line.strip()) for line in file2]

    # Find the point of symmetry
    # if the length of file is even (because of the padding)
    # makes it uneven so the symmetry point is at the right place
    symmetry_point = (len(float_values_1) - (1 - len(float_values_1) % 2)) // 2

    # Get the directory of the input files
    input_dir = os.path.dirname(file_path_1)

    # Write the combined hex values to a new file in the same directory
    hex_output_file_path = os.path.join(input_dir, "CoeffWriter_Archi1.vhd")
    with open(hex_output_file_path, 'w') as hex_output_file:
        # Write the hex values from file 1 above the symmetry point
        hex_output_file.write("""ARCHITECTURE Archi1 OF CoeffWriter IS
    constant HALF_FILTER_TAP_NB : positive := FILTER_TAP_NB/2 + 
    (FILTER_TAP_NB mod 2);
    signal firstWrite : unsigned(3 downto 0);
    signal wAddrCnt : unsigned(addressBitNb - 1 downto 0);
    signal arrayCnt : unsigned(addressBitNb - 1 downto 0);
    signal writeCoeffs : std_ulogic;

    constant n : positive := 1;
    constant initialWAddress : integer := 1502;
    constant RAMLength : positive := (((FILTER_TAP_NB * n * 2) + 
    initialWAddress) - 1);
    -- lowpass firtst then highpass coeff
    type coefficients is array (0 to 1, 0 to HALF_FILTER_TAP_NB - 1) of 
    signed(COEFF_BIT_NB - 1 downto 0);
    signal coeff : coefficients := (
    (      """)
        for i, value in enumerate(float_values_2):
            if i < symmetry_point:
                hex_value = float_to_twos_complement_hex(value)
                hex_output_file.write('x"' + hex_value + '",')
                if (i + 1) % 5 == 0:
                    hex_output_file.write("\n           ")
            if i == symmetry_point:
                hex_value = float_to_twos_complement_hex(value)
                hex_output_file.write('x"' + hex_value + '"' + "\n")
                hex_output_file.write("     ),")

        # Write the hex values from file 2 above the symmetry point
        hex_output_file.write("\n     (     ")
        for i, value in enumerate(float_values_1):
            if i < symmetry_point:
                hex_value = float_to_twos_complement_hex(value)
                hex_output_file.write('x"' + hex_value + '",')
                if (i + 1) % 5 == 0:
                    hex_output_file.write("\n           ")
            if i == symmetry_point:
                hex_value = float_to_twos_complement_hex(value)
                hex_output_file.write('x"' + hex_value + '"' + "\n")
                hex_output_file.write("""     )
   );
begin
   RamWriter : process (clock, reset)
   begin
      if (reset = '1') then
         firstWrite <= (others => '0');
         arrayCnt <= (others => '0');
         wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
         writeCoeffs <= '1';
      elsif rising_edge(clock) then
         if writeCoeffs = '1' then
            wAddrCnt <= wAddrCnt + n;
            addressB <= std_ulogic_vector(wAddrCnt);
            writeEnB <= '1';
            enB <= '1';
            if arrayCnt <= HALF_FILTER_TAP_NB - 1 then
               if firstWrite = 0 then
                  firstWrite <= firstWrite + 1;
                  dataInB <= std_ulogic_vector(unsigned(
                  coeff(1, to_integer(arrayCnt))
                  (COEFF_BIT_NB - 1 downto (COEFF_BIT_NB - (COEFF_BIT_NB/2)))));
               end if;
               if firstWrite = 1 then
                  firstWrite <= firstWrite + 1;
                  dataInB <= std_ulogic_vector(unsigned(
                  coeff(1, to_integer(arrayCnt))
                     ((COEFF_BIT_NB - (COEFF_BIT_NB/2) - 1) downto 0)));
               end if;
               if firstWrite = 2 then
                  firstWrite <= firstWrite + 1;
                  dataInB <= std_ulogic_vector(unsigned(
                  coeff(0, to_integer(arrayCnt))
                  (COEFF_BIT_NB - 1 downto (COEFF_BIT_NB - (COEFF_BIT_NB/2)))));
               end if;
               if firstWrite = 3 then
                  arrayCnt <= arrayCnt + 1;
                  firstWrite <= (others => '0');
                  dataInB <= std_ulogic_vector(unsigned(
                  coeff(0, to_integer(arrayCnt))
                  ((COEFF_BIT_NB - (COEFF_BIT_NB/2) - 1) downto 0)));
               end if;
            end if;
            if arrayCnt = HALF_FILTER_TAP_NB and firstWrite = 0 then
               writeCoeffs <= '0';
               enB <= '0';
               writeEnB <= '0';
               wAddrCnt <= to_unsigned(initialWAddress, wAddrCnt'length);
            end if;
         end if;
      end if;
   end process RamWriter;  
END ARCHITECTURE Archi1;""")

    log_message(f"Combined hex values above symmetry point written to: {hex_output_file_path}")


def send_rs232(file_path):
    selected_com_port = com_var.get()

    try:
        ser = serial.Serial(selected_com_port, baudrate=9600, bytesize=serial.SEVENBITS, parity=serial.PARITY_NONE,
                            stopbits=serial.STOPBITS_ONE)
    except serial.SerialException:
        show_error_message("Error: Unable to open serial port. Check the COM port.")
        return

    with open(file_path, 'r') as input_file:
        data = input_file.read()

        total_bytes = len(data)
        current_byte = 0

        # Create and display the progress bar
        global progress_bar
        progress_bar = ttk.Progressbar(root, orient='horizontal', length=300, mode='determinate')
        progress_bar.grid(row=6, column=0, columnspan=3, padx=10, pady=10)

        for char in data:
            ser.write(char.encode())
            current_byte += 1
            update_progress_bar(current_byte, total_bytes)
        for char in "x!00000000!   ":
            ser.write(char.encode())
            current_byte += 1
            update_progress_bar(current_byte, total_bytes)

    ser.close()
    # Close and reset the progress bar
    progress_bar.grid_forget()
    progress_bar = None

    # Remove the error label
    global error_label
    if error_label:
        error_label.destroy()

    log_message("Data sent through RS232.")


def log_message(message):
    console_text.config(state=tk.NORMAL)  # Enable editing
    console_text.insert(tk.END, message + '\n')
    console_text.config(state=tk.DISABLED)  # Disable editing
    console_text.see(tk.END)  # Scroll to the end


# Create the main window and other GUI elements...
root = tk.Tk()
root.title("FIR Lin Xover Programmer")

# Create labels
file_1_label = tk.Label(root, text="Highpass Coefficients:")
file_2_label = tk.Label(root, text="Lowpass Coefficients :")

# Create entry fields
file_1_entry = tk.Entry(root)
file_2_entry = tk.Entry(root)

# Create browse buttons
browse_button_1 = tk.Button(root, text="Browse", command=browse_file_1)
browse_button_2 = tk.Button(root, text="Browse", command=browse_file_2)

# Create Send new filter button
process_button = tk.Button(root, text="Send New Filter", command=process_files)

# Create create hex file button
create_hex_button = tk.Button(root, text="Create VHDL File", command=create_hex_file)

# Arrange widgets using grid layout
file_1_label.grid(row=0, column=0)
file_2_label.grid(row=1, column=0)
file_1_entry.grid(row=0, column=1, padx=10, pady=5)
file_2_entry.grid(row=1, column=1, padx=10, pady=5)
browse_button_1.grid(row=0, column=2, padx=5, pady=5)
browse_button_2.grid(row=1, column=2, padx=5, pady=5)
process_button.grid(row=2, columnspan=2, padx=10, pady=10)
create_hex_button.grid(row=2, column=2, padx=10, pady=10)

# Create a scrolling menu for selecting the gain
gain_label = tk.Label(root, text="Gain:")
gain_label.grid(row=4, column=0, padx=10, pady=5)

gain_var = tk.IntVar(value=10)
gain_menu = ttk.Combobox(root, textvariable=gain_var, values=list(range(1, 16)))
gain_menu.grid(row=4, column=1, padx=10, pady=5)

# Create the "Send Gain" button
send_button = tk.Button(root, text="Send Gain", command=send_gain)
send_button.grid(row=4, column=2, padx=5, pady=5)

# Create a scrolling menu for selecting the COM port
com_label = tk.Label(root, text="COM Port:")
com_label.grid(row=3, column=0, padx=10, pady=5)

# Get the list of available COM ports
available_ports = ["COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
                   "COM10", "COM11", "COM12", "COM13", "COM14", "COM15", "COM16", "COM17", "COM18", "COM19", "COM20"]
com_var = tk.StringVar(value=available_ports[0])
com_menu = ttk.Combobox(root, textvariable=com_var, values=available_ports)
com_menu.grid(row=3, column=1, padx=10, pady=5)

# Create a text widget to display messages
console_text = tk.Text(root, wrap=tk.WORD, height=10, state=tk.DISABLED)
console_text.grid(row=5, column=0, columnspan=3, padx=10, pady=10, sticky=tk.W + tk.E)

# Start the GUI event loop
root.mainloop()
