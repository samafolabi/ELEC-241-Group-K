library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_controller is
	generic(
		T_BITS 				:	integer := 7
	);
	port(
		STATE					:	in std_logic;
		CHANGED				:	in std_logic;
		ANGLE					:	in std_logic_vector(T_BITS-1 downto 0);
		FEEDBACK_A			:	in std_logic;
		FEEDBACK_B			:	in std_logic;
		
		--Outputs
		GOING					:	out std_logic;
		MOTOR_A				:	out std_logic;
		MOTOR_B				:	out std_logic
	);
end entity;

architecture rtl of encoder_controller is
	signal old_angle : std_logic_vector(T_BITS-1 downto 0) := (others => '0');
	signal cnt, turns, max : integer := 0;
	signal dir : std_logic := '0'; --0 for cw, 1 for ccw
begin
	
	process(CHANGED, FEEDBACK_A, FEEDBACK_B)
		variable r, l, x : integer := 0;
	begin
		if (rising_edge(CHANGED) and STATE = '1') then
			r := to_integer(unsigned(ANGLE)) - to_integer(unsigned(old_angle));
			l := to_integer(unsigned(old_angle)) - to_integer(unsigned(ANGLE));
			if (abs(r) < abs(l)) then x := r; else x := l; end if;
			if (x < 0) then
				turns <= 0;
				max <= x;
				dir <= '0';
			else
				turns <= 0;
				max <= x;
				dir <= '1';
			end if;
		end if;
		
		if (rising_edge(FEEDBACK_A)) then
			if (dir = '0' and cnt = 0) then
				cnt <= 1;
			elsif (dir = '1' and cnt = 1)
				cnt <= 2;
			end if;
		elsif (rising_edge(FEEDBACK_B)) then
			if (dir = '0' and cnt = 1) then
				cnt <= 2;
			elsif (dir = '1' and cnt = 0)
				cnt <= 1;
			end if;
		elsif (falling_edge(FEEDBACK_A)) then
			if (dir = '0' and cnt = 2) then
				cnt <= 3;
			elsif (dir = '1' and cnt = 3)
				cnt <= 0;
				turns <= turns + 1;
			end if;
		elsif (falling_edge(FEEDBACK_B)) then
			if (dir = '0' and cnt = 3) then
				cnt <= 0;
				turns <= turns + 1;
			elsif (dir = '1' and cnt = 2)
				cnt <= 3;
			end if;
		end if;
	end process;
	
	process(turns)
	begin
		if (turns = 0) then
			if (max < 0) then
				GOING <= '1';
				MOTOR_A <= '1'; --CW
			else
				GOING <= '1';
				MOTOR_B <= '1'; --CCW
			end if;
		elsif (turns = abs(max))
			GOING <= '0';
			MOTOR_A <= '0';
			MOTOR_B <= '0';
		end if;
	end process;

end rtl;