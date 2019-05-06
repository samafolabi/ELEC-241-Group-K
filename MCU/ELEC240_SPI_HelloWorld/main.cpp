#include "mbed.h"

#define DD 25                   //Display Delay us
#define CD 2000                 //Command Delay us
#define READ_CONFIG 0xF000			//Read the FIFO_CONFIG
#define READ_ADC 0x0F00					//Read from FIFO buffer
#define READ_SPACE 0xFF00				//Read the space available
#define WRITE_CONFIG 0x0000			//Write to FIFO_CONFIG
#define RESET 0x01							//FIFO_CONFIG - RESET
#define SAMP 0x02								//FIFO_CONFIG - SAMP
#define OVERFLOW 0x40						//FIFO_CONFIG - OVERFLOW
#define AVAIL 0x80							//FIFO_CONFIG - AVAIL
#define SAMP_SIZE	8							// Size of sample FIFO buffer
#define RESOLUTION 12
#define VREFOFFSET 360

SPI spi(PA_7, PA_6, PA_5);      // Ordered as: mosi, miso, sclk could use forth parameter ssel
                                // However using multi SPI devices within FPGA with a seperate chip select
SPI spi_cmd(PA_7, PA_6, PA_5);  // NB another instance call spi_cmd for 8 bit SPI dataframe see later line 37
                                // For each device NB PA_7 PA_6 PA_5 are D11 D12 D13 respectively
DigitalOut cs(PC_6);            // Chip Select for Basic Outputs to illuminate Onboard FPGA DEO nano LEDs CN7 pin 1
DigitalOut LCD_cs(PB_15);       // Chip Select for the LCD via FPGA CN7 pin 3
DigitalOut SERVO_cs(PB_9);        // Chip Select for the ADC via FPGA CN7 pin 4
InterruptIn user(USER_BUTTON);
Timer timer;

//Function Prototypes, will just output a string to display, see later
int32_t bar_graph(uint8_t level);   //Display a bar graph on the lcd 2nd line scale 0 to 15
void pulse_bar_graph(void);         //Show a quick Bar up down and clear
int32_t read_adc(void);             //Read ADC and return the 12 Bit value 0 to 4095 NB has a 3V3 refernce voltage (for scaling)
int32_t read_switches(void);        //Read 4 Sliding switches on FPGA (Simulating OPTO-Switches from Motor(s)

int32_t lcd_cls(void);              //LCD Functions here, Clear Screen, Locate and Display String
int32_t lcd_locate(uint8_t line, uint8_t column); //Line Max is 2, Column max is 16
int32_t lcd_display(char* str);     //String str length maximum is 16

void init(void);	//initialization functions
void screen_setup(void);	//clear the screen and put welcome messages
void risingEdge(void);
void fallingEdge(void);
int spi_write(int cmd);
short power_calc(int arr[]);

char num[] = "0123456789";
char val[4];
unsigned int getVolt(unsigned short stored);
char* convertVolt(unsigned int value);

int samp_en = 0;
int samples[SAMP_SIZE], overflow_samp[SAMP_SIZE];

//NBB the following line for F429ZI !!!!
DigitalIn DO_NOT_USE(PB_12);    // MAKE PB_12 (D19) an INPUT do NOT make an OUTPUT under any circumstances !!!!! ************* !!!!!!!!!!!
                                // This Pin is connected to the 5VDC from the FPGA card and an INPUT is 5V Tolerant

//Ticker ticktock;
 
int main() {
	
	init();
	
	//set RESET bit when MCU resets
	spi_write(WRITE_CONFIG | RESET);
	
	screen_setup();
	
	int samp_en = 0;
	
	//req 3-2
	user.rise(callback(&risingEdge));
	
	while(true)
	{
		
		int i = 0; //sample counter
		
		__disable_irq();
		while(samp_en)
		{
			int data = spi_write(WRITE_CONFIG | (AVAIL | OVERFLOW));
			
			if (data & OVERFLOW)
			{
				/*for (int j = 0; j < SAMP_SIZE; j++)
				{
					overflow_samp[j] = spi_write(READ_ADC);
				}
				spi_write(WRITE_CONFIG | SAMP);*/
				//reset or stop everything and read all in one swoop (the sampling will still occur)
				continue;
			}
			
			if (data & AVAIL)
			{
				samples[i] = spi_write(READ_ADC);
				i = (i+1 == SAMP_SIZE) ? 0 : i+1;
			}
		}
		__enable_irq();
		
		//req 3-5
		lcd_locate(1,8);
		lcd_display(convertVolt(getVolt(power_calc(samples))));
		
	}
    
	/*int adval_d = 0;            //A to D value read back
	float adval_f =0.0f;
	int err = 0;                //error variable used for debugging, trapping etc.,
	char adval[32];
 
	while(true)                 //Loop forever Knight Rider Display on FPGA
	{
			adval_d = read_adc();
			
			adval_f = 3.3f*((float)adval_d/4095);//Convert 12 bit to a float and scale
			sprintf(adval,"%.3f",adval_f);       //Store in an array string
			lcd_locate(1,8);                     //and display on LCD
			lcd_display(adval);                  //
			
			err = bar_graph(adval_d/255);       // 16*256 =4096 12 bit ADC!
			if (err < 0){printf("Display Overload\r\n");}
			wait_ms(50);
			
			read_switches();
			//LED Chaser display KIT lives on!
			for (uint32_t i=1;i<=128;i*=2)
			{
					cs = 0;             //Select the device by seting chip select LOW
					spi_cmd.write(0);
					spi.write(i);
					cs = 1;             //De-Select the device by seting chip select HIGH
					wait_ms(20);
			}
			for (uint32_t i=128;i>=1;i/=2)
			{
					cs = 0;             //Select the device by seting chip select LOW
					spi_cmd.write(0);
					spi.write(i);
					cs = 1;             //De-Select the device by seting chip select HIGH
					wait_ms(20);
			}
	}*/
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
	lcd_locate(1,1);
	lcd_display(splash_screen1);    //Credit line 1
	lcd_locate(2,2);
	lcd_display(splash_screen2);    //Credit line 2
	wait(2);
	lcd_cls();
	pulse_bar_graph(); //Flashy bargraph clear screen  
	lcd_locate(1,0);
	lcd_display(DVM);   //Type Voltage display
	lcd_locate(1,13);
	lcd_display("V");   //Units display
}


void risingEdge(void){
	user.rise(NULL);
	user.fall(callback(&fallingEdge));
	timer.start();
}
void fallingEdge(void){
	timer.stop();
	user.fall(NULL);
	if (timer.read() >= 0.1) //switch debounce
	{
		spi_write(WRITE_CONFIG | SAMP);
		samp_en = 1;
	}
	timer.reset();
}
int spi_write(int cmd){
	//tell the cmd
	cs = 0;
	spi.write(cmd);
	cs = 1;
	wait_ms(1);
	//get the data
	cs = 0;
	int data = spi.write(cmd);
	cs = 1;
	return data;
}
short power_calc(int arr[]){
	int no_dc_samps[SAMP_SIZE];
	int mean_1 = 0, mean_2 = 0, sum_1 = 0, sum_2 = 0;
	for (int i = 0; i < SAMP_SIZE; i++) {
		sum_1 += arr[i];
	}
	mean_1 /= SAMP_SIZE;
	for (int i = 0; i < SAMP_SIZE; i++) {
		no_dc_samps[i] = (arr[i] - mean_1) * (arr[i] - mean_1);
	}
	for (int i = 0; i < SAMP_SIZE; i++) {
		sum_2 += no_dc_samps[i];
	}
	mean_2 /= SAMP_SIZE;
	return (short) mean_2;
}
unsigned int getVolt(unsigned short stored)
{
	unsigned int offsetVal = (stored*100)/(1<<RESOLUTION);
	offsetVal *= VREFOFFSET;
	return offsetVal/100;
}

char* convertVolt(unsigned int value)
{
	val[0] = num[value/100];
	val[1] = '.';
	val[2] = num[(value%100)/10];
	val[3] = num[(value%100)%10];
	return val;
}
int lcd_cls(void){
    LCD_cs = 0;spi_cmd.write(0);spi.write(0x0001);LCD_cs = 1;wait_us(CD);    //Clear Screen
    return 0;
}

int lcd_locate(uint8_t line, uint8_t column){
    uint8_t line_addr;
    uint8_t column_addr;
    switch(line){
        case 1: line_addr=0x80; break;
        case 2: line_addr=0xC0; break;
        default: return -1; //return code !=0 is error
        }
    if(column<16){column_addr=column;}
    else{return -1;}
    LCD_cs = 0;
    spi_cmd.write(0);
    spi.write(line_addr+column_addr);
    LCD_cs = 1;
    wait_us(CD); //DDRAM location Second line is 0x00C0 first line starts at 0x0080
    return 0;
}

int lcd_display(char* str){
    
    if (strlen(str)>16){return -1;} //return code !=0 is error
    
    uint8_t command_data=1;
    uint32_t wait_time;
 
    switch(command_data){
        case 0: wait_time=DD; break;
        case 1: wait_time=CD; break;
        default: return -1;
        }

    for (int i=0; i<strlen(str);i++){
        LCD_cs = 0;
        spi_cmd.write(0);
        spi.write((command_data<<8)+str[i]);
        LCD_cs = 1;
        wait_us(wait_time);
    }
    return 0;
}

int bar_graph(uint8_t level){
    if (level>16){return -1;} //return code !=0 is error
    LCD_cs = 0;spi_cmd.write(0);spi.write(0x00C0);LCD_cs = 1;wait_us(CD); //DDRAM location Second line is 0x00C0 first line starts at 0x0080
    for (int i=1; i<=level ;i++)
    {
        if(level>0){LCD_cs = 0;spi_cmd.write(0);spi.write(0x01FF);LCD_cs = 1;wait_us(DD);}   // BLACK SPACE
        else{LCD_cs = 0;spi_cmd.write(0);spi.write(0x0120);LCD_cs = 1;wait_us(DD);}          // WHITE SPACE
    }
    for (int i=level; i<=16 ;i++)
    {
        LCD_cs = 0;spi_cmd.write(0);spi.write(0x0120);LCD_cs = 1;wait_us(DD); // SPACE
    }
    return 0; // return code ==0 is OK
}

int read_adc(void){/*
    int adval_d;
    float adval_f;
    ADC_cs = 0;
    adval_d = spi.write(0x00);
    ADC_cs =1 ;
    adval_f = 3.3f*((float)adval_d/4095);
    printf("%d %.3fV\r\n",adval_d,adval_f);
    return adval_d;   */ 
}

void pulse_bar_graph(void){
    for (uint8_t i=0;i<16;i++)
    {
        printf("%u\r\n",i);
        bar_graph(i);
        wait_ms(100);
    }
    for (int8_t i=15;i>=0;i--)
    {
        printf("%u\r\n",i);
        bar_graph(i);
        wait_ms(100);
    }
}

int read_switches(void){
    int sw_val;
    cs = 0;
    spi_cmd.write(0);
    sw_val = spi.write(0x00)&0x0F; // Just want lower 4bit nibble
    cs = 1 ;
    if (sw_val&(1<<0)){printf("Switch 0 :");}
    if (sw_val&(1<<1)){printf("Switch 1 :");}
    if (sw_val&(1<<2)){printf("Switch 2 :");}
    if (sw_val&(1<<3)){printf("Switch 3 :");}
    if (sw_val>0){printf("\r\n");}
    return sw_val;    
}
