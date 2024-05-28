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
	//�������䣬��������0
	Xil_Out16(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_DTR_OFFSET,0); //���� SPI ���䣬����ʱ�Ӻ�Ƭѡ�ź�

	return 0;
}

void My_ISR(){

	int status = Xil_In32(XPAR_AXI_INTC_0_BASEADDR+XIN_ISR_OFFSET); //�����ж�״̬
	if((status&XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)==XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)
		switchHandler();
	//������ز������жϣ�����뿪���жϷ�����
	else if((status&XPAR_AXI_TIMER_0_INTERRUPT_MASK)==XPAR_AXI_TIMER_0_INTERRUPT_MASK)
		timerHandler();
	//�����ʱ���������жϣ�����붨ʱ���жϷ�����
	else if((status & XPAR_AXI_QUAD_SPI_0_IP2INTC_IRPT_MASK) == XPAR_AXI_QUAD_SPI_0_IP2INTC_IRPT_MASK)
	    SPIHandler();

	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_IAR_OFFSET,status);
}

void switchHandler() {//�����жϷ������

	int sw = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA_OFFSET); //���뿪��ֵ

	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,sw); //�ѿ��ص�״̬��ӳ�� LED��
	Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_ISR_OFFSET,0x01);

	int min=6000000; //���ʱ��60ms
	RESET_VALUE=((sw&0x0000ffff)*1434+min)/0xfff-2;
	//����ֵ 1434=�����ʱ��100000000-��Сʱ��6000000��/2^16��=65536�� ÿ����һ�����ؼ�һ������ʱ��
	//����Ŀ���ֵsw����0x0000ffff�����16λ

	//�������е��Ƕ�ʱ����ʼ�����˴����ظı��˶�ʱ����Ԥ��ֵ������Ҫ����װ��
	int status=Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET);
	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,status&(~XTC_CSR_ENABLE_TMR_MASK));
	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TLR_OFFSET,RESET_VALUE); //Ϊ��ʱ��װ�ظı���Ԥ��ֵ
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
	    Xil_In32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XIN_ISR_OFFSET)); //���ж�

}

 void timerHandler() {//��ݲ��γ�

	 volt++;//�����ݲ���ÿ�ж�һ�Σ�����������źţ�1

	 Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET));
	 //�嶨ʱ���жϣ���Ȼһֱ�ж����ڻ᲻��
	 Xil_Out16(XPAR_SPI_0_BASEADDR+XSP_DTR_OFFSET,volt&0xfff);
	 		 //����SPI���䣬����ʱ�Ӻ�Ƭѡ�źţ��������ݣ���Ч����Ϊ��12λ
	 Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,0x8); //��ͨ�ж�ģʽ���ֶ����ж�

}
void Init(){

	//�趨SPI�ӿڵ�ͨ��ģʽ���趨SPIΪ���豸��CPOL=1,CPHA-0,ʱ����λ180�㣬�Զ���ʽ����λ���ȴ���
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_CR_OFFSET,XSP_CR_ENABLE_MASK|XSP_CR_MASTER_MODE_MASK|XSP_CR_CLK_POLARITY_MASK);
	//�趨SSR�Ĵ���
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_SSR_OFFSET,0xfffffffe);
	//����SPI���ͼĴ������ж�
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_IIER_OFFSET,XSP_INTR_TX_EMPTY_MASK);
	//�ж�ԴΪSPI �ӿڷ����������ź�������ж�
	Xil_Out32(XPAR_AXI_QUAD_SPI_0_BASEADDR+XSP_DGIER_OFFSET,XSP_GINTR_ENABLE_MASK);
	//����SPI �ӿڵ��ж����

	//GPIO �ж�ʹ��
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_TRI_OFFSET,0xffff);//���� switch ����Ϊ����
	Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_TRI2_OFFSET,0X0);
	//LED ����Ϊ���
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_IER_OFFSET,XGPIO_IR_CH1_MASK);//GPIO_0 �ж�ʹ��
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_GIE_OFFSET,XGPIO_GIE_GINTR_ENABLE_MASK);
	//GPIO_0 ȫ���ж�ʹ��

	//��ʱ����ʼ��
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET,
			Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)&~XTC_CSR_ENABLE_TMR_MASK);//дTCSR��ֹͣ��ʱ��
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TLR_OFFSET,RESET_VALUE);//д TLR��Ԥ�ü�����ֵ
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET,
			Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)|XTC_CSR_LOAD_MASK);
	//װ�ؼ�����ֵ
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET,
			(Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)&~XTC_CSR_LOAD_MASK)
			|XTC_CSR_ENABLE_TMR_MASK|XTC_CSR_AUTO_RELOAD_MASK
			|XTC_CSR_ENABLE_INT_MASK|XTC_CSR_DOWN_COUNT_MASK);//��ʼ��ʱ ������ȡ�����жϼ�����

	//�жϿ�����intr0�ж�Դʹ��
	Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IER_OFFSET,XPAR_AXI_TIMER_0_INTERRUPT_MASK|
			XPAR_AXI_QUAD_SPI_0_IP2INTC_IRPT_MASK|XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK);
	//���Ŷ�ʱ��T0��SPI�ж�
	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_MER_OFFSET,XIN_INT_MASTER_ENABLE_MASK
			|XIN_INT_HARDWARE_ENABLE_MASK);
	//�������ж�ʹ��
}
