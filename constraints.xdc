# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
	
##Buttons
set_property PACKAGE_PIN U18 	 [get_ports rst]						
set_property IOSTANDARD LVCMOS33 [get_ports rst]

##VGA Connector
set_property PACKAGE_PIN G19     [get_ports {rgb[11]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[11]}]
set_property PACKAGE_PIN H19     [get_ports {rgb[10]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[10]}]
set_property PACKAGE_PIN J19     [get_ports {rgb[9]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[9]}]
set_property PACKAGE_PIN N19     [get_ports {rgb[8]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[8]}]
set_property PACKAGE_PIN J17     [get_ports {rgb[7]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[7]}]
set_property PACKAGE_PIN H17     [get_ports {rgb[6]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[6]}]
set_property PACKAGE_PIN G17     [get_ports {rgb[5]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[5]}]
set_property PACKAGE_PIN D17     [get_ports {rgb[4]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[4]}]
set_property PACKAGE_PIN N18     [get_ports {rgb[3]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[3]}]
set_property PACKAGE_PIN L18     [get_ports {rgb[2]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[2]}]
set_property PACKAGE_PIN K18     [get_ports {rgb[1]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[1]}]
set_property PACKAGE_PIN J18     [get_ports {rgb[0]}]				
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[0]}]
set_property PACKAGE_PIN P19     [get_ports hsync]						
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19     [get_ports vsync]						
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

#Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {keypad_col[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[0]}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {keypad_col[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[1]}]
#Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {keypad_col[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[2]}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {keypad_col[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col[3]}]
#Sch name = JA7
set_property PACKAGE_PIN H1 [get_ports {keypad_row[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[4]}]
#Sch name = JA8
set_property PACKAGE_PIN K2 [get_ports {keypad_row[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[5]}]
#Sch name = JA9
set_property PACKAGE_PIN H2 [get_ports {keypad_row[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[6]}]
#Sch name = JA10
set_property PACKAGE_PIN G3 [get_ports {keypad_row[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row[7]}]

# LED Signals (showing game state)
set_property PACKAGE_PIN P3 [get_ports led[0]] 
set_property PACKAGE_PIN N3 [get_ports led[1]]  
set_property PACKAGE_PIN P1 [get_ports led[2]]   
set_property PACKAGE_PIN L1 [get_ports led[3]]  
set_property IOSTANDARD LVCMOS33 [get_ports {led[0] led[1] led[2] led[3]}]