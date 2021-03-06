library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity adc_controller_test is
end adc_controller_test;

architecture v1 of adc_controller_test is
signal CLK,EN,ADC_IN_DATA,SCLK,CS_N,SADDR,DATA_READY : std_logic := '0';
signal ADC_OUT_DATA : std_logic_vector(11 downto 0);

constant T_CLK : time := 10 ns; --20 ns is 50MHz, so half that for clock toggle
constant T_END : time := 1000 ns;

procedure wait_fall is
begin
	wait until (CLK'EVENT and CLK = '0');
end wait_fall;

procedure wait_rise is
begin
	wait until (CLK'EVENT and CLK = '1');
end wait_rise;

component adc_controller
	port(
		CLK			:	in std_logic;
		EN				:	in std_logic;
		ADC_IN_DATA	:	in std_logic;
		
		SCLK			:	out std_logic;
		CS_N			:	out std_logic;
		SADDR			:	out std_logic;
		DATA_READY	: 	out std_logic;
		ADC_OUT_DATA:	out std_logic_vector(11 downto 0)
	);
end component;

begin
	u1 : adc_controller port map (
		CLK,EN,ADC_IN_DATA,SCLK,CS_N,SADDR,DATA_READY,ADC_OUT_DATA
	);
	
	clock : process
		variable t : time := 0 ns;
	begin
		loop
			t := t + T_CLK;
			wait for T_CLK;
			CLK <= not CLK;
			exit when t >= T_END;
		end loop;
		wait;
	end process clock;
	
	main : process
	begin
		
		EN <= '1';
		wait for 100 ns;
		wait_rise;
		EN <= '0';
		wait_fall;--0
		wait_fall;
		wait_fall;
		wait_fall;
		wait_fall;--3
		wait_rise;--3
		ADC_IN_DATA <= '1';
		wait_fall;--4
		wait_rise;--4
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;--15
		
		wait_fall;-- -1
		wait_fall;-- 0
		
		wait_fall;--1 fall
		wait_fall;
		wait_fall;
		wait_fall;--3
		wait_rise;--3
		ADC_IN_DATA <= '1';
		wait_fall;--4
		wait_rise;--4
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '0';
		wait_fall;
		wait_rise;
		ADC_IN_DATA <= '1';
		wait_fall;
		wait_rise;--15
		wait_fall;-- -1
		
		wait_rise;
		EN <= '1';
		
	wait;
	end process main;
END v1;
