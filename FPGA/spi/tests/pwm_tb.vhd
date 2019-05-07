library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity pwm_test is
end pwm_test;

architecture v1 of pwm_test is
signal clk, rst, en, pwm_out : std_logic := '0';

constant T_CLK : time := 20 ns;
constant T_END : time := 500 ns;

procedure wait_fall is
begin
	wait until (CLK'DELAYED(1 ps)'EVENT and CLK = '0');
end wait_fall;

procedure wait_rise is
begin
	wait until (CLK'DELAYED(1 ps)'EVENT and CLK = '1');
end wait_rise;

component pwm
	generic (
	 duty     			: std_logic_vector(4 downto 0) := "11100";
	 PWM_RESOLUTION	: natural := 5;			-- PWM resolution in bits
	 SYS_CLK    	     : natural := 50_000;		-- System clock in kHz
	 PWM_CLK  	     : natural := 250			-- PWM clock in kHz
  );
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
 
    -- signals from top module to registers sub-module
    en       : in std_logic;		
    pwm_out  : out std_logic
  );
end component;

begin
	u1 : pwm port map (
		clk, rst, en, pwm_out
	);
	
	clock : process
		variable t : time := 0 ns;
	begin
		loop
			t := t + T_CLK/2;
			wait for T_CLK/2;
			clk <= not clk;
			exit when t >= T_END;
		end loop;
		wait;
	end process clock;
	
	main : process
	begin
		
		rst <= '0';
		en <= '1';
		wait for 0 ns;
		wait for 400 ns;
		
	wait;
	end process main;
END v1;
