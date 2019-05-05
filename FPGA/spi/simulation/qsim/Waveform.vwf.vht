-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "05/03/2019 17:43:05"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          spi_test
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY spi_test_vhd_vec_tst IS
END spi_test_vhd_vec_tst;
ARCHITECTURE spi_test_arch OF spi_test_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL ADC_CS : STD_LOGIC;
SIGNAL ADC_CS_N : STD_LOGIC;
SIGNAL ADC_SADDR : STD_LOGIC;
SIGNAL ADC_SCLK : STD_LOGIC;
SIGNAL ADC_SDAT : STD_LOGIC;
SIGNAL CLK : STD_LOGIC;
SIGNAL CLOCK_1_OP : STD_LOGIC;
SIGNAL CLR : STD_LOGIC;
SIGNAL CS_N : STD_LOGIC;
SIGNAL IN1 : STD_LOGIC;
SIGNAL IN2 : STD_LOGIC;
SIGNAL IN3 : STD_LOGIC;
SIGNAL LCD_CS_N : STD_LOGIC;
SIGNAL LCD_D0 : STD_LOGIC;
SIGNAL LCD_D1 : STD_LOGIC;
SIGNAL LCD_D2 : STD_LOGIC;
SIGNAL LCD_D3 : STD_LOGIC;
SIGNAL LCD_D4 : STD_LOGIC;
SIGNAL LCD_D5 : STD_LOGIC;
SIGNAL LCD_D6 : STD_LOGIC;
SIGNAL LCD_D7 : STD_LOGIC;
SIGNAL LCD_E : STD_LOGIC;
SIGNAL LCD_RS : STD_LOGIC;
SIGNAL LCD_RW : STD_LOGIC;
SIGNAL LED_0 : STD_LOGIC;
SIGNAL LED_1 : STD_LOGIC;
SIGNAL LED_2 : STD_LOGIC;
SIGNAL LED_3 : STD_LOGIC;
SIGNAL LED_4 : STD_LOGIC;
SIGNAL LED_5 : STD_LOGIC;
SIGNAL LED_6 : STD_LOGIC;
SIGNAL LED_7 : STD_LOGIC;
SIGNAL MISO : STD_LOGIC;
SIGNAL MOSI_IN : STD_LOGIC;
SIGNAL OUT1 : STD_LOGIC;
SIGNAL OUT2 : STD_LOGIC;
SIGNAL OUT3 : STD_LOGIC;
SIGNAL READ_REQ : STD_LOGIC;
SIGNAL RESET_BUTTON : STD_LOGIC;
SIGNAL SCLK_IN : STD_LOGIC;
SIGNAL SPACE1 : STD_LOGIC;
SIGNAL SPACE2 : STD_LOGIC;
SIGNAL SPACE3 : STD_LOGIC;
SIGNAL Switch_0 : STD_LOGIC;
SIGNAL Switch_1 : STD_LOGIC;
SIGNAL Switch_2 : STD_LOGIC;
SIGNAL Switch_3 : STD_LOGIC;
SIGNAL WRITE_REQ : STD_LOGIC;
SIGNAL X50MHz_CLK : STD_LOGIC;
COMPONENT spi_test
	PORT (
	ADC_CS : IN STD_LOGIC;
	ADC_CS_N : OUT STD_LOGIC;
	ADC_SADDR : OUT STD_LOGIC;
	ADC_SCLK : OUT STD_LOGIC;
	ADC_SDAT : IN STD_LOGIC;
	CLK : IN STD_LOGIC;
	CLOCK_1_OP : OUT STD_LOGIC;
	CLR : IN STD_LOGIC;
	CS_N : IN STD_LOGIC;
	IN1 : IN STD_LOGIC;
	IN2 : IN STD_LOGIC;
	IN3 : IN STD_LOGIC;
	LCD_CS_N : IN STD_LOGIC;
	LCD_D0 : OUT STD_LOGIC;
	LCD_D1 : OUT STD_LOGIC;
	LCD_D2 : OUT STD_LOGIC;
	LCD_D3 : OUT STD_LOGIC;
	LCD_D4 : OUT STD_LOGIC;
	LCD_D5 : OUT STD_LOGIC;
	LCD_D6 : OUT STD_LOGIC;
	LCD_D7 : OUT STD_LOGIC;
	LCD_E : OUT STD_LOGIC;
	LCD_RS : OUT STD_LOGIC;
	LCD_RW : OUT STD_LOGIC;
	LED_0 : OUT STD_LOGIC;
	LED_1 : OUT STD_LOGIC;
	LED_2 : OUT STD_LOGIC;
	LED_3 : OUT STD_LOGIC;
	LED_4 : OUT STD_LOGIC;
	LED_5 : OUT STD_LOGIC;
	LED_6 : OUT STD_LOGIC;
	LED_7 : OUT STD_LOGIC;
	MISO : OUT STD_LOGIC;
	MOSI_IN : IN STD_LOGIC;
	OUT1 : OUT STD_LOGIC;
	OUT2 : OUT STD_LOGIC;
	OUT3 : OUT STD_LOGIC;
	READ_REQ : IN STD_LOGIC;
	RESET_BUTTON : IN STD_LOGIC;
	SCLK_IN : IN STD_LOGIC;
	SPACE1 : OUT STD_LOGIC;
	SPACE2 : OUT STD_LOGIC;
	SPACE3 : OUT STD_LOGIC;
	Switch_0 : IN STD_LOGIC;
	Switch_1 : IN STD_LOGIC;
	Switch_2 : IN STD_LOGIC;
	Switch_3 : IN STD_LOGIC;
	WRITE_REQ : IN STD_LOGIC;
	X50MHz_CLK : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : spi_test
	PORT MAP (
-- list connections between master ports and signals
	ADC_CS => ADC_CS,
	ADC_CS_N => ADC_CS_N,
	ADC_SADDR => ADC_SADDR,
	ADC_SCLK => ADC_SCLK,
	ADC_SDAT => ADC_SDAT,
	CLK => CLK,
	CLOCK_1_OP => CLOCK_1_OP,
	CLR => CLR,
	CS_N => CS_N,
	IN1 => IN1,
	IN2 => IN2,
	IN3 => IN3,
	LCD_CS_N => LCD_CS_N,
	LCD_D0 => LCD_D0,
	LCD_D1 => LCD_D1,
	LCD_D2 => LCD_D2,
	LCD_D3 => LCD_D3,
	LCD_D4 => LCD_D4,
	LCD_D5 => LCD_D5,
	LCD_D6 => LCD_D6,
	LCD_D7 => LCD_D7,
	LCD_E => LCD_E,
	LCD_RS => LCD_RS,
	LCD_RW => LCD_RW,
	LED_0 => LED_0,
	LED_1 => LED_1,
	LED_2 => LED_2,
	LED_3 => LED_3,
	LED_4 => LED_4,
	LED_5 => LED_5,
	LED_6 => LED_6,
	LED_7 => LED_7,
	MISO => MISO,
	MOSI_IN => MOSI_IN,
	OUT1 => OUT1,
	OUT2 => OUT2,
	OUT3 => OUT3,
	READ_REQ => READ_REQ,
	RESET_BUTTON => RESET_BUTTON,
	SCLK_IN => SCLK_IN,
	SPACE1 => SPACE1,
	SPACE2 => SPACE2,
	SPACE3 => SPACE3,
	Switch_0 => Switch_0,
	Switch_1 => Switch_1,
	Switch_2 => Switch_2,
	Switch_3 => Switch_3,
	WRITE_REQ => WRITE_REQ,
	X50MHz_CLK => X50MHz_CLK
	);

-- CLK
t_prcs_CLK: PROCESS
BEGIN
LOOP
	CLK <= '0';
	WAIT FOR 20000 ps;
	CLK <= '1';
	WAIT FOR 20000 ps;
	IF (NOW >= 1000000 ps) THEN WAIT; END IF;
END LOOP;
END PROCESS t_prcs_CLK;

-- CLR
t_prcs_CLR: PROCESS
BEGIN
	CLR <= '0';
WAIT;
END PROCESS t_prcs_CLR;

-- IN1
t_prcs_IN1: PROCESS
BEGIN
	FOR i IN 1 TO 3
	LOOP
		IN1 <= '0';
		WAIT FOR 160000 ps;
		IN1 <= '1';
		WAIT FOR 160000 ps;
	END LOOP;
	IN1 <= '0';
WAIT;
END PROCESS t_prcs_IN1;

-- IN2
t_prcs_IN2: PROCESS
BEGIN
	FOR i IN 1 TO 6
	LOOP
		IN2 <= '0';
		WAIT FOR 80000 ps;
		IN2 <= '1';
		WAIT FOR 80000 ps;
	END LOOP;
	IN2 <= '0';
WAIT;
END PROCESS t_prcs_IN2;

-- IN3
t_prcs_IN3: PROCESS
BEGIN
	FOR i IN 1 TO 12
	LOOP
		IN3 <= '0';
		WAIT FOR 40000 ps;
		IN3 <= '1';
		WAIT FOR 40000 ps;
	END LOOP;
	IN3 <= '0';
WAIT;
END PROCESS t_prcs_IN3;

-- READ_REQ
t_prcs_READ_REQ: PROCESS
BEGIN
	READ_REQ <= '0';
	WAIT FOR 260000 ps;
	READ_REQ <= '1';
	WAIT FOR 200000 ps;
	READ_REQ <= '0';
WAIT;
END PROCESS t_prcs_READ_REQ;

-- WRITE_REQ
t_prcs_WRITE_REQ: PROCESS
BEGIN
	WRITE_REQ <= '0';
	WAIT FOR 20000 ps;
	WRITE_REQ <= '1';
	WAIT FOR 160000 ps;
	WRITE_REQ <= '0';
WAIT;
END PROCESS t_prcs_WRITE_REQ;
END spi_test_arch;
