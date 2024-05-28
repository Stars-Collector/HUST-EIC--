/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include "xil_io.h"
#include "xil_exception.h"
#include "xintc_l.h"
#include "xspi_l.h"
#include "xtmrctr_l.h"
#include "xgpio_l.h"
#include "xparameters.h"

int RESET_VALUE = 100000000/0xfff-2;
u16 volt=0;

void My_ISR() __attribute__((interrupt_handler));
void switchHandler();
void SPIHandler();
void timerHandler();
void Init();

int main(){

	RESET_VALUE = 100000000/0xfff-2;
	Init();
	microblaze_enable_interrupts();
	//启动传输，发送数据0
	Xil_Out16(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_DTR_OFFSET,0); //启动 SPI 传输，产生时钟和片选信号

	return 0;
}

void My_ISR(){

	int status = Xil_In32(XPAR_AXI_INTC_0_BASEADDR+XIN_ISR_OFFSET); //读入中断状态
	if((status&XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)==XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)
		switchHandler();
	//如果开关产生了中断，则进入开关中断服务函数
	else if((status&XPAR_AXI_TIMER_0_INTERRUPT_MASK)==XPAR_AXI_TIMER_0_INTERRUPT_MASK)
		timerHandler();
	//如果定时器产生了中断，则进入定时器中断服务函数
	else if((status & XPAR_AXI_QUAD_SPI_0_IP2INTC_IRPT_MASK) == XPAR_AXI_QUAD_SPI_0_IP2INTC_IRPT_MASK)
	    SPIHandler();

	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_IAR_OFFSET,status);
}

void switchHandler() {//开关中断服务程序

	int sw = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA_OFFSET); //读入开关值

	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,sw); //把开关的状态反映到 LED上
	Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_ISR_OFFSET,0x01);

	int min=6000000; //最短时间60ms
	RESET_VALUE=((sw&0x0000ffff)*1434+min)/0xfff-2;
	//步进值 1434=（最大时长100000000-最小时长6000000）/2^16（=65536） 每拨动一个开关加一个步进时长
	//读入的开关值sw与上0x0000ffff保存低16位

	//主程序中的是定时器初始化，此处开关改变了定时器的预置值，故需要重新装载
	int status=Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET);
	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,status&(~XTC_CSR_ENABLE_TMR_MASK));
	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TLR_OFFSET,RESET_VALUE); //为定时器装载改变后的预置值
	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,
			Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET)|XTC_CSR_LOAD_MASK);

	status = (status&(~XTC_CSR_LOAD_MASK))|XTC_CSR_ENABLE_TMR_MASK
	    		|XTC_CSR_AUTO_RELOAD_MASK|XTC_CSR_ENABLE_INT_MASK|XTC_CSR_DOWN_COUNT_MASK;
	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,status);
}

void SPIHandler() {

	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_IISR_OFFSET,
	    Xil_In32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_IISR_OFFSET));

	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_IAR_OFFSET,
	    Xil_In32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XIN_ISR_OFFSET)); //清中断

}

 void timerHandler() {//锯齿波形成

	 volt++;//输出锯齿波，每中断一次，输出的数字信号＋1

	 Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET));
	 //清定时器中断，不然一直中断周期会不对
	 Xil_Out16(XPAR_SPI_0_BASEADDR+XSP_DTR_OFFSET,volt&0xfff);
	 		 //启动SPI传输，产生时钟和片选信号，发送数据，有效数据为低12位
	 Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,0x8); //普通中断模式，手动清中断

}
void Init(){

	//设定SPI接口的通信模式，设定SPI为主设备，CPOL=1,CPHA-0,时钟相位180°，自动方式，高位优先传送
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_CR_OFFSET,XSP_CR_ENABLE_MASK|XSP_CR_MASTER_MODE_MASK|XSP_CR_CLK_POLARITY_MASK);
	//设定SSR寄存器
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_SSR_OFFSET,0xfffffffe);
	//开放SPI发送寄存器空中断
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_IIER_OFFSET,XSP_INTR_TX_EMPTY_MASK);
	//中断源为SPI 接口发送完数字信号则产生中断
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_DGIER_OFFSET,XSP_GINTR_ENABLE_MASK);
	//开启SPI 接口的中断输出

	//GPIO 中断使能
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_TRI_OFFSET,0xffff);//开关 switch 设置为输入
	Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_TRI2_OFFSET,0X0);
	//LED 设置为输出
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_IER_OFFSET,XGPIO_IR_CH1_MASK);//GPIO_0 中断使能
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_GIE_OFFSET,XGPIO_GIE_GINTR_ENABLE_MASK);
	//GPIO_0 全局中断使能

	//定时器初始化
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET,
			Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)&~XTC_CSR_ENABLE_TMR_MASK);//写TCSR，停止定时器
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TLR_OFFSET,RESET_VALUE);//写 TLR，预置计数初值
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET,
			Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)|XTC_CSR_LOAD_MASK);
	//装载计数初值
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET,
			(Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)&~XTC_CSR_LOAD_MASK)
			|XTC_CSR_ENABLE_TMR_MASK|XTC_CSR_AUTO_RELOAD_MASK
			|XTC_CSR_ENABLE_INT_MASK|XTC_CSR_DOWN_COUNT_MASK);//开始计时 自主获取允许中断减计数

	//中断控制器intr0中断源使能
	Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IER_OFFSET,XPAR_AXI_TIMER_0_INTERRUPT_MASK|
			XPAR_AXI_QUAD_SPI_0_IP2INTC_IRPT_MASK|XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK);
	//开放定时器T0及SPI中断
	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_MER_OFFSET,XIN_INT_MASTER_ENABLE_MASK
			|XIN_INT_HARDWARE_ENABLE_MASK);
	//处理器中断使能
}
