
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
   set_property BOARD_PART digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_uartlite:2.0\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:axi_intc:4.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:axi_timer:2.0\
xilinx.com:ip:axi_quad_spi:3.2\
xilinx.com:ip:system_ila:1.1\
xilinx.com:ip:lmb_v10:3.0\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:blk_mem_gen:8.4\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB

  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB


  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property CONFIG.C_ECC {0} $dlmb_bram_if_cntlr


  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property CONFIG.C_ECC {0} $ilmb_bram_if_cntlr


  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.use_bram_block {BRAM_Controller} \
  ] $lmb_bram


  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins dlmb_v10/LMB_M] [get_bd_intf_pins DLMB]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_v10/LMB_Sl_0] [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ilmb_v10/LMB_M] [get_bd_intf_pins ILMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_v10/LMB_Sl_0] [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set usb_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart ]

  set dip_switches_16bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 dip_switches_16bits ]

  set led_16bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led_16bits ]

  set seven_seg_led_an [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 seven_seg_led_an ]

  set dual_seven_seg_led_disp [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 dual_seven_seg_led_disp ]

  set push_buttons_5bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 push_buttons_5bits ]

  set rgb_led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 rgb_led ]


  # Create ports
  set sys_clock [ create_bd_port -dir I -type clk -freq_hz 100000000 sys_clock ]
  set_property -dict [ list \
   CONFIG.PHASE {0.0} \
 ] $sys_clock
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset
  set MOSI [ create_bd_port -dir O MOSI ]
  set SCLK0 [ create_bd_port -dir O SCLK0 ]
  set SS0 [ create_bd_port -dir O -from 0 -to 0 SS0 ]
  set MISO [ create_bd_port -dir I MISO ]
  set SCLK1 [ create_bd_port -dir O SCLK1 ]
  set SS1 [ create_bd_port -dir O -from 0 -to 0 SS1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0 ]
  set_property -dict [list \
    CONFIG.C_DEBUG_ENABLED {1} \
    CONFIG.C_D_AXI {1} \
    CONFIG.C_D_LMB {1} \
    CONFIG.C_I_LMB {1} \
  ] $microblaze_0


  # Create instance: mdm_0, and set properties
  set mdm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_0 ]
  set_property -dict [list \
    CONFIG.C_ADDR_SIZE {32} \
    CONFIG.C_DBG_MEM_ACCESS {1} \
    CONFIG.C_M_AXI_ADDR_WIDTH {32} \
  ] $mdm_0


  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
    CONFIG.RESET_BOARD_INTERFACE {reset} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $clk_wiz_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [list \
    CONFIG.RESET_BOARD_INTERFACE {reset} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $proc_sys_reset_0


  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [list \
    CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $axi_uartlite_0


  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [list \
    CONFIG.NUM_MI {10} \
    CONFIG.NUM_SI {2} \
  ] $microblaze_0_axi_periph


  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_INTERRUPT_PRESENT {1} \
    CONFIG.GPIO2_BOARD_INTERFACE {led_16bits} \
    CONFIG.GPIO_BOARD_INTERFACE {dip_switches_16bits} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $axi_gpio_0


  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [list \
    CONFIG.GPIO2_BOARD_INTERFACE {dual_seven_seg_led_disp} \
    CONFIG.GPIO_BOARD_INTERFACE {seven_seg_led_an} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $axi_gpio_1


  # Create instance: axi_gpio_2, and set properties
  set axi_gpio_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_2 ]
  set_property -dict [list \
    CONFIG.C_INTERRUPT_PRESENT {1} \
    CONFIG.GPIO2_BOARD_INTERFACE {rgb_led} \
    CONFIG.GPIO_BOARD_INTERFACE {push_buttons_5bits} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $axi_gpio_2


  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0 ]
  set_property CONFIG.C_HAS_FAST {1} $axi_intc_0


  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property CONFIG.NUM_PORTS {7} $xlconcat_0


  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]

  # Create instance: axi_uartlite_1, and set properties
  set axi_uartlite_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_1 ]

  # Create instance: axi_uartlite_2, and set properties
  set axi_uartlite_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_2 ]

  # Create instance: axi_quad_spi_0, and set properties
  set axi_quad_spi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_0 ]
  set_property -dict [list \
    CONFIG.C_NUM_TRANSFER_BITS {16} \
    CONFIG.C_SCK_RATIO {4} \
    CONFIG.C_USE_STARTUP {0} \
  ] $axi_quad_spi_0


  # Create instance: axi_quad_spi_1, and set properties
  set axi_quad_spi_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_1 ]
  set_property -dict [list \
    CONFIG.C_NUM_TRANSFER_BITS {16} \
    CONFIG.C_SCK_RATIO {4} \
    CONFIG.C_USE_STARTUP {0} \
  ] $axi_quad_spi_1


  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {MIX} \
    CONFIG.C_NUM_MONITOR_SLOTS {2} \
    CONFIG.C_NUM_OF_PROBES {3} \
    CONFIG.C_PROBE0_TYPE {0} \
    CONFIG.C_PROBE1_TYPE {0} \
    CONFIG.C_PROBE2_TYPE {0} \
    CONFIG.C_SLOT_0_APC_EN {0} \
    CONFIG.C_SLOT_0_AXI_AR_SEL_DATA {1} \
    CONFIG.C_SLOT_0_AXI_AR_SEL_TRIG {1} \
    CONFIG.C_SLOT_0_AXI_AW_SEL_DATA {1} \
    CONFIG.C_SLOT_0_AXI_AW_SEL_TRIG {1} \
    CONFIG.C_SLOT_0_AXI_B_SEL_DATA {1} \
    CONFIG.C_SLOT_0_AXI_B_SEL_TRIG {1} \
    CONFIG.C_SLOT_0_AXI_R_SEL_DATA {1} \
    CONFIG.C_SLOT_0_AXI_R_SEL_TRIG {1} \
    CONFIG.C_SLOT_0_AXI_W_SEL_DATA {1} \
    CONFIG.C_SLOT_0_AXI_W_SEL_TRIG {1} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
    CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:mbinterrupt_rtl:1.0} \
    CONFIG.C_SLOT_1_TYPE {0} \
  ] $system_ila_0


  # Create interface connections
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports dip_switches_16bits] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO2 [get_bd_intf_ports led_16bits] [get_bd_intf_pins axi_gpio_0/GPIO2]
  connect_bd_intf_net -intf_net axi_gpio_1_GPIO [get_bd_intf_ports seven_seg_led_an] [get_bd_intf_pins axi_gpio_1/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_1_GPIO2 [get_bd_intf_ports dual_seven_seg_led_disp] [get_bd_intf_pins axi_gpio_1/GPIO2]
  connect_bd_intf_net -intf_net axi_gpio_2_GPIO [get_bd_intf_ports push_buttons_5bits] [get_bd_intf_pins axi_gpio_2/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_2_GPIO2 [get_bd_intf_ports rgb_led] [get_bd_intf_pins axi_gpio_2/GPIO2]
  connect_bd_intf_net -intf_net axi_intc_0_interrupt [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]
connect_bd_intf_net -intf_net [get_bd_intf_nets axi_intc_0_interrupt] [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins system_ila_0/SLOT_1_MBINTERRUPT]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets axi_intc_0_interrupt]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports usb_uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net mdm_0_M_AXI [get_bd_intf_pins mdm_0/M_AXI] [get_bd_intf_pins microblaze_0_axi_periph/S01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI] [get_bd_intf_pins axi_uartlite_0/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI] [get_bd_intf_pins axi_gpio_1/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI] [get_bd_intf_pins axi_gpio_2/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI] [get_bd_intf_pins axi_intc_0/s_axi]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI] [get_bd_intf_pins axi_timer_0/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
connect_bd_intf_net -intf_net [get_bd_intf_nets microblaze_0_axi_periph_M06_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI] [get_bd_intf_pins system_ila_0/SLOT_0_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets microblaze_0_axi_periph_M06_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI] [get_bd_intf_pins axi_quad_spi_1/AXI_LITE]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M08_AXI [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI] [get_bd_intf_pins axi_uartlite_1/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M09_AXI [get_bd_intf_pins microblaze_0_axi_periph/M09_AXI] [get_bd_intf_pins axi_uartlite_2/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_0/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]

  # Create port connections
  connect_bd_net -net axi_gpio_0_ip2intc_irpt [get_bd_pins axi_gpio_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_gpio_2_ip2intc_irpt [get_bd_pins axi_gpio_2/ip2intc_irpt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_quad_spi_0_io0_o [get_bd_pins axi_quad_spi_0/io0_o] [get_bd_ports MOSI] [get_bd_pins system_ila_0/probe0]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axi_quad_spi_0_io0_o]
  connect_bd_net -net axi_quad_spi_0_ip2intc_irpt [get_bd_pins axi_quad_spi_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net axi_quad_spi_0_sck_o [get_bd_pins axi_quad_spi_0/sck_o] [get_bd_ports SCLK0] [get_bd_pins system_ila_0/probe1]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axi_quad_spi_0_sck_o]
  connect_bd_net -net axi_quad_spi_0_ss_o [get_bd_pins axi_quad_spi_0/ss_o] [get_bd_ports SS0] [get_bd_pins system_ila_0/probe2]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axi_quad_spi_0_ss_o]
  connect_bd_net -net axi_quad_spi_1_ip2intc_irpt [get_bd_pins axi_quad_spi_1/ip2intc_irpt] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net axi_quad_spi_1_sck_o [get_bd_pins axi_quad_spi_1/sck_o] [get_bd_ports SCLK1]
  connect_bd_net -net axi_quad_spi_1_ss_o [get_bd_pins axi_quad_spi_1/ss_o] [get_bd_ports SS1]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net axi_uartlite_1_interrupt [get_bd_pins axi_uartlite_1/interrupt] [get_bd_pins xlconcat_0/In5]
  connect_bd_net -net axi_uartlite_1_tx [get_bd_pins axi_uartlite_1/tx] [get_bd_pins axi_uartlite_2/rx]
  connect_bd_net -net axi_uartlite_2_interrupt [get_bd_pins axi_uartlite_2/interrupt] [get_bd_pins xlconcat_0/In6]
  connect_bd_net -net axi_uartlite_2_tx [get_bd_pins axi_uartlite_2/tx] [get_bd_pins axi_uartlite_1/rx]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net io1_i_0_1 [get_bd_ports MISO] [get_bd_pins axi_quad_spi_1/io1_i]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_0/Debug_SYS_Rst] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins mdm_0/M_AXI_ACLK] [get_bd_pins microblaze_0_axi_periph/S01_ACLK] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins axi_gpio_2/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins axi_intc_0/processor_clk] [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins axi_quad_spi_0/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins axi_quad_spi_1/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins axi_uartlite_1/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M08_ACLK] [get_bd_pins axi_uartlite_2/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/M09_ACLK] [get_bd_pins system_ila_0/clk]
  connect_bd_net -net proc_sys_reset_0_bus_struct_reset [get_bd_pins proc_sys_reset_0/bus_struct_reset] [get_bd_pins microblaze_0_local_memory/SYS_Rst]
  connect_bd_net -net proc_sys_reset_0_mb_reset [get_bd_pins proc_sys_reset_0/mb_reset] [get_bd_pins microblaze_0/Reset] [get_bd_pins axi_intc_0/processor_rst]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins mdm_0/M_AXI_ARESETN] [get_bd_pins microblaze_0_axi_periph/S01_ARESETN] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins axi_gpio_2/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins axi_quad_spi_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins axi_quad_spi_1/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins axi_uartlite_1/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins axi_uartlite_2/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M09_ARESETN] [get_bd_pins system_ila_0/resetn]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins clk_wiz_0/resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins axi_quad_spi_1/ext_spi_clk] [get_bd_pins axi_quad_spi_0/ext_spi_clk]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_pins axi_intc_0/intr]

  # Create address segments
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_2/S_AXI/Reg] -force
  assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_intc_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_quad_spi_0/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x44A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_quad_spi_1/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x41C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40600000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40610000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x40620000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_2/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00008000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0x00000000 -range 0x00008000 -target_address_space [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_gpio_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_gpio_2/S_AXI/Reg] -force
  assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_intc_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_quad_spi_0/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x44A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_quad_spi_1/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x41C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40600000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40610000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_uartlite_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x40620000 -range 0x00010000 -target_address_space [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_uartlite_2/S_AXI/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


