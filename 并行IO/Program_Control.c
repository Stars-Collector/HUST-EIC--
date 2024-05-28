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
#include "xgpio_l.h"

#define AXI_GPIO_0_BASEADDR 0x40000000
#define AXI_GPIO_1_BASEADDR 0x40010000
#define AXI_GPIO_2_BASEADDR 0x40020000

void display(char segcode[], short tmp, short position);

int main() {

    init_platform();

    unsigned short lastSwitchState, currentSwitchState;  //switch state at last cycle and this cycle 
    unsigned short led;  // output to LED

    Xil_Out16(AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);  // set switch as input 
    Xil_Out16(AXI_GPIO_0_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);  // set LED as output

    unsigned short currentButton, lastButton, realButton;

    char segcode[6] = {0xc6, 0xc1, 0xc7, 0x88, 0xa1, 0xff}; 
    // seg signal as {C, U, L, R, D, null} 
    short tmp = 0;

    short position = 0xff7f;//0111_1111

    Xil_Out8(AXI_GPIO_1_BASEADDR + XGPIO_TRI_OFFSET, 0x0);//an 
    Xil_Out8(AXI_GPIO_1_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);//seg_led 
    Xil_Out16(AXI_GPIO_2_BASEADDR + XGPIO_TRI_OFFSET, 0x1f);//buttons

    while (1) { 
 
        currentSwitchState = Xil_In16(AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET);

        if (lastSwitchState != currentSwitchState)  // change switch state when switch toggle 
            led = currentSwitchState; 
        
        Xil_Out16(AXI_GPIO_0_BASEADDR + XGPIO_DATA2_OFFSET, led);  // output to LED 
        display(segcode, tmp, position);  // show on seg
 
        currentButton = Xil_In8(AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET) & 0x1f;
        //only five buttons
        if (currentButton) {  // Button Clicked 
            while (currentButton) {  // Button not spring up 

                display(segcode, tmp, position); 

                currentButton = (Xil_In8(AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET) & 0x1f); 
                realButton = (currentButton ^ lastButton) & lastButton;  // Button unpressed
                lastButton = currentButton;

                if (realButton) { 
                    break; 
                } 
            } 
            // judge which Button was pressed 
            switch (realButton) { 
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
        }

        lastSwitchState = currentSwitchState; 
    }
    
    cleanup_platform();
    return 0;
}

void display(char segcode[], short tmp, short position) { 
     
    for (int i = 0; i < 8; i++) {

        Xil_Out8(AXI_GPIO_1_BASEADDR + XGPIO_DATA2_OFFSET, segcode[tmp]);  // display signal at each bit 
        Xil_Out8(AXI_GPIO_1_BASEADDR + XGPIO_DATA_OFFSET, position);  // position change 
        
        for (int j = 0; j < 10000; j++);  // light on 8 segs 
            position = position >> 1; 
    } 
} 
