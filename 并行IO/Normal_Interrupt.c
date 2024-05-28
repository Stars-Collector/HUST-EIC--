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

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xgpio.h"
#include "xintc_l.h"
#include "xtmrctr_l.h"
#include "xil_exception.h"
#include "xparameters.h"

#define RESET_VALUE 100000
// #define XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK 0X000001U
// #define XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK 0X000002U
// #define XPAR_AXI_TIMER_0_INTERRUPT_MASK 0X000004U 

void segTimerCounterHandler();
void My_ISR()  __attribute__((interrupt_handler)); 
void buttonHandler();
void switchHandler();

unsigned short currentbutton, lastbutton, realbutton;
short tmp; 
int i = 0;
int k = 0; 
short position = 0xff7f;
char segcode[6] = {0xc6, 0xc1, 0xc7, 0x88, 0xa1, 0xff};


int main()
{
    init_platform();

    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);  // set LED as output 
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);  // Switch as output

    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK);
    //< Interrupt enable register 
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_GIE_OFFSET, 
    XGPIO_GIE_GINTR_ENABLE_MASK);
    //< Glogal interrupt enable register 
    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IER_OFFSET, 
    XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK); 
    // interrupt channel 
    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_MER_OFFSET, XIN_INT_MASTER_ENABLE_MASK | 
    XIN_INT_HARDWARE_ENABLE_MASK);

    Xil_Out32(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI_OFFSET, 0x0); 
    // set seg show signal as output 
    Xil_Out32(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI2_OFFSET, 0x0); 
    // set seg position signal as output 
    
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_TRI_OFFSET, 0x1f); 
    // button input 
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK); 
    // allow channel 1 interrupt 
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_GIE_OFFSET, 
    XGPIO_GIE_GINTR_ENABLE_MASK); 
    // allow GPIO interrupt output

    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET, 
              Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) & 
                    ~XTC_CSR_ENABLE_TMR_MASK); 
    // write TCSR(Control/Status register), stop counter 
    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TLR_OFFSET, RESET_VALUE); 
    // write TLR(Load register), preset counter value 
    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET, 
              Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) | 
                        XTC_CSR_LOAD_MASK); 
    // get counter initial value 
    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET, 
                (Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) & 
                    ~XTC_CSR_LOAD_MASK) | XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_AUTO_RELOAD_MASK
                     | XTC_CSR_ENABLE_INT_MASK | XTC_CSR_DOWN_COUNT_MASK); 

    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IER_OFFSET, 
                XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK | XPAR_AXI_TIMER_0_INTERRUPT_MASK);
    //Enable the interrupt controller 
    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_MER_OFFSET, XIN_INT_MASTER_ENABLE_MASK | 
                XIN_INT_HARDWARE_ENABLE_MASK); 
    microblaze_enable_interrupts();  // allow microbalze enable interrupt  
        
    cleanup_platform();
    return 0;
}

void buttonHandler() { 
    int buttoncode; 
    buttoncode = Xil_In32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET); 
    switch (buttoncode) { 
        case 0x01:  
            tmp = 0;  
            break; 
        case 0x02:  
            tmp = 1;  
            break; 
        case 0x04:  
            tmp = 2;  
            break; 
        case 0x08:  
            tmp = 3;  
            break; 
        case 0x10:  
            tmp = 4;  
            break; 
    } 
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_ISR_OFFSET, 
        Xil_In32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_ISR_OFFSET)); 
}

void My_ISR() {//interrupt service routine

    int status = Xil_In32(XPAR_AXI_INTC_0_BASEADDR + XIN_ISR_OFFSET);

    if((status & XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK) == 
            XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)  
            switchHandler();
             
    //Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IAR_OFFSET, status); 
    if ((status & XPAR_AXI_TIMER_0_INTERRUPT_MASK) == XPAR_AXI_TIMER_0_INTERRUPT_MASK)  
        segTimerCounterHandler();

    if ((status & XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK) == 
            XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK) 
        buttonHandler(); 
    
    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IAR_OFFSET, status);  
}
 
void switchHandler() { 

    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA2_OFFSET, 
            Xil_In32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET));

    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_ISR_OFFSET, 
            Xil_In32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_ISR_OFFSET)); 
}

void segTimerCounterHandler() {

    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA2_OFFSET, segcode[tmp]); 
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA_OFFSET, position);
     
    position = position >> 1; 
    i++;

    if (i == 8) { 
        i = 0; 
        position = 0xff7f; 
    } 
    
    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET, 
        Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET));
    // clear interrupt 
}