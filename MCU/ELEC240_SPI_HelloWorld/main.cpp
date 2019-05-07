#include "mbed.h"
#include "math.h"

#define DD 25                   //Display Delay us
#define CD 2000                 //Command Delay us
#define READ_CONFIG 0xF000			//Read the FIFO_CONFIG
#define READ_ADC 0x0F00					//Read from FIFO buffer
#define READ_SPACE 0xFF00				//Read the space available
#define WRITE_CONFIG 0x0000			//Write to FIFO_CONFIG
#define RESET 0x0001						//FIFO_CONFIG - RESET
#define SAMP 0x0002							//FIFO_CONFIG - SAMP
#define AVAIL 0x0004						//FIFO_CONFIG - AVAIL
#define OVERFLOW 0x0008					//FIFO_CONFIG - OVERFLOW
#define SAMP_SIZE	8							//Size of sample FIFO buffer
#define RESOLUTION 12						//ADC Resolution
#define MBITS 8									//Angle Resolution
#define VREFOFFSET 330					//Voltage reference offset

SPI spi(PA_7, PA_6, PA_5);      // Ordered as: mosi, miso, sclk could use forth parameter ssel
                                // However using multi SPI devices within FPGA with a seperate chip select
SPI spi_cmd(PA_7, PA_6, PA_5);  // NB another instance call spi_cmd for 8 bit SPI dataframe see later line 37
                                // For each device NB PA_7 PA_6 PA_5 are D11 D12 D13 respectively
DigitalOut cs(PC_6);            // Chip Select for Basic Outputs to illuminate Onboard FPGA DEO nano LEDs CN7 pin 1
DigitalOut LCD_cs(PB_15);       // Chip Select for the LCD via FPGA CN7 pin 3
DigitalOut SERVO_cs(PB_13);     // Chip Select for the ADC via FPGA CN7 pin 4
InterruptIn user(USER_BUTTON);	// Blue user button
Timer timer;										// Button switch debounce timer

int32_t lcd_cls(void);              							//Clear LCD Screen
int32_t lcd_locate(uint8_t line, uint8_t column); //Locate Cursor, Line Max is 2, Column max is 16
int32_t lcd_display(char* str);     							//Display String, str length maximum is 16

void init(void);										//initialization functions
void screen_setup(void);						//clear the screen and put welcome messages
void risingEdge(void);							//rising edge of button
void fallingEdge(void);							//falling edge of button
unsigned short spi_write(int cmd);	//write cmd and data to spi
short power_calc(int arr[]);				//calculate mean squared value of samples
char* angle_calc(short angle);

const char num[] = "0123456789";							//number to string conversion
char val[4];																	//value of the power calculation in string form
char val_a[3];																	//value of angle calculation in string form
unsigned int getVolt(unsigned short stored);	//get offset voltage value from adc data
char* convertVolt(unsigned int value);				//convert offset voltage value to a string

int samp_en = 0;					//sample enable
int samples[SAMP_SIZE];		//samples array
char* rst = "RST!";	//reset string

//NBB the following line for F429ZI !!!!
DigitalIn DO_NOT_USE(PB_12);    // MAKE PB_12 (D19) an INPUT do NOT make an OUTPUT under any circumstances !!!!! ************* !!!!!!!!!!!
                                // This Pin is connected to the 5VDC from the FPGA card and an INPUT is 5V Tolerant


int test_samples[] = {246, 123, 489, 798, 932, 135, 384, 947};
int test_angles[] = {512, 256, 768};

int main() {
	
	init();
	
	//set RESET bit when MCU resets
	spi_write(RESET);
	wait_ms(20);
	
	screen_setup();
	wait(0.5);
	
	unsigned short data;
	
	while(true)
	{
		for (int i = 0; i < 8; i++){
		lcd_locate(1,8); //calculate the mean squared value and display on LCD
		lcd_display(convertVolt(getVolt(power_calc(test_samples))));
		test_samples[i] += 10;
		lcd_locate(2,0);
		lcd_display(angle_calc(test_angles[i]));
		lcd_display(" degrees");
		
		wait(1);
		}
		
		/*int i = 0; //sample counter
		user.rise(callback(&risingEdge)); //attach the button trigger
		
		__disable_irq(); //safety for samp_en
		while(samp_en)
		{
			int data = spi_write(READ_CONFIG); //get FIFO_CONFIG
			
			if (data & OVERFLOW) //if it is overflowing, reset the buffer and add a RST! message
			{
				spi_write(RESET);
				lcd_locate(1,8);
				lcd_display(rst);
				continue;
			}
			
			if (data & AVAIL) //if there are samples available, read from the adc and add to the sample array
			{
				samples[i] = spi_write(READ_ADC);
				i = (i+1 == SAMP_SIZE) ? 0 : i+1;
			}
			
			lcd_locate(1,8); //calculate the mean squared value and display on LCD
			lcd_display(convertVolt(getVolt(power_calc(samples))));
			
		}
		__enable_irq();*/
		
	}
    
	
}



void init(void) {
	//SPI setup
	cs = 1;                     // Chip must be deselected, Chip Select is active LOW
	LCD_cs = 1;                 // Chip must be deselected, Chip Select is active LOW
	SERVO_cs = 1;                 // Chip must be deselected, Chip Select is active LOW
	spi.format(16,0);           // Setup the DATA frame SPI for 16 bit wide word, Clock Polarity 0 and Clock Phase 0 (0)
	spi_cmd.format(8,0);        // Setup the COMMAND SPI as 8 Bit wide word, Clock Polarity 0 and Clock Phase 0 (0)
	spi.frequency(1000000);     // 1MHz clock rate
	spi_cmd.frequency(1000000); // 1MHz clock rate
}
void screen_setup(void){
	//Loading and start screens
	char splash_screen1[]="AfolAndrNanoSche";
	char splash_screen2[]="ELEC241 Group K";
	char DVM[]="Voltage=";
	
	lcd_cls();
	lcd_locate(1,0);
	lcd_display(splash_screen1);
	lcd_locate(2,2);
	lcd_display(splash_screen2);
	wait(1);
	
	lcd_cls(); 
	lcd_locate(1,0);
	lcd_display(DVM);
	lcd_locate(1,12);
	lcd_display("V");
}
void risingEdge(void){
	user.rise(NULL); //remove rising trigger, add falling trigger, and start timer
	user.fall(callback(&fallingEdge));
	timer.start();
}
void fallingEdge(void){
	timer.stop(); //stop timer, check if time has been longer than 0.1s (debounce), and if so, write to the FPGA to start sampling,
	if (timer.read() >= 0.1) //remove falling trigger, tell the MCU it has started sampling, and reset timer. If not, resume timer
	{
		spi_write(SAMP);
		samp_en = 1;
		user.fall(NULL);
		timer.reset();
	} else {
		timer.start();
	}
}
unsigned short spi_write(int cmd){
	//set the cmd
	cs = 0;
	spi.write(cmd);
	cs = 1;
	wait_ms(1);
	
	//get the data
	cs = 0;
	unsigned short data = spi.write(cmd);
	cs = 1;
	return data;
}
short power_calc(int arr[]){
	int no_dc_samps[SAMP_SIZE];
	int mean_1 = 0, mean_2 = 0, sum_1 = 0, sum_2 = 0;
	
	for (int i = 0; i < SAMP_SIZE; i++) { //calculate the average
		sum_1 += arr[i];
	}
	mean_1 /= SAMP_SIZE;
	
	for (int i = 0; i < SAMP_SIZE; i++) { //remove the average from the samples and sqaure them
		no_dc_samps[i] = (arr[i] - mean_1) * (arr[i] - mean_1);
	}
	
	for (int i = 0; i < SAMP_SIZE; i++) { //calculate the average of the new samples
		sum_2 += no_dc_samps[i];
	}
	mean_2 /= SAMP_SIZE;
	
	return (short) mean_2;
}
char* angle_calc(short angle){
	angle = round((360 * angle) / MBITS);
	val_a[0] = num[angle/100]; //construct a string
	val_a[1] = num[(angle%100)/10];
	val_a[2] = num[(angle%100)%10];
	return val_a;
}
unsigned int getVolt(unsigned short stored){
	unsigned int offsetVal = (stored*100)/(1<<RESOLUTION); //get the fraction of the ADC data compared to the max value and offset it
	offsetVal *= VREFOFFSET; //calculate the offset fraction in proportion to the offset voltage reference
	return offsetVal/100; //remove some of the offset
}

char* convertVolt(unsigned int value){
	val[0] = num[value/100]; //use the offset value to construct a string
	val[1] = '.';
	val[2] = num[(value%100)/10];
	val[3] = num[(value%100)%10];
	return val;
}
int lcd_cls(void){
    LCD_cs = 0; //Clear Screen
		spi_cmd.write(0);
		spi.write(0x0001);
		LCD_cs = 1;
		wait_us(CD);
    return 0;
}

int lcd_locate(uint8_t line, uint8_t column){
    uint8_t line_addr; //move to DDRAM location, with the first line = 0x0080 and the second line = 0x00C0
    uint8_t column_addr;
	
    switch(line){
        case 1:
					line_addr=0x80;
					break;
        case 2:
					line_addr=0xC0;
					break;
        default:
					return -1; //return code !=0 is error
    }
		
    if (column < 16) {
			column_addr = column;
		} else{
			return -1;
		}
    LCD_cs = 0;
    spi_cmd.write(0);
    spi.write(line_addr + column_addr);
    LCD_cs = 1;
    wait_us(CD);
    return 0;
}

int lcd_display(char* str){
    
    if (strlen(str) > 16) { //make sure the string is less than or equal to 16 characters, then display each character
			return -1;
		}
    
    uint8_t command_data = 1;
    uint32_t wait_time;
 
    switch(command_data){
        case 0:
					wait_time = DD;
					break;
        case 1:
					wait_time = CD;
					break;
        default:
					return -1;
    }

    for (int i = 0; i < strlen(str); i++){
        LCD_cs = 0;
        spi_cmd.write(0);
        spi.write((command_data<<8) + str[i]);
        LCD_cs = 1;
        wait_us(wait_time);
    }
    return 0;
}
