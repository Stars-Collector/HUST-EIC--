#Pmod Header JA

set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { SS1[0] }]; #IO_L20N_T3_A19_15 Sch=ja[1]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { MISO }]; #IO_L21N_T3_DQS_A18_15 Sch=ja[2]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { SCLK1 }]; #IO_L18N_T2_A23_15 Sch=ja[4]
#Pmod Header JB

set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { SS0[0] }]; #IO_L1P_T0_AD0P_15 Sch=jb[1]
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { MOSI }]; #IO_L14N_T2_SRCC_15 Sch=jb[2]
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { SCLK0 }]; #IO_L15P_T2_DQS_15 Sch=jb[4]
