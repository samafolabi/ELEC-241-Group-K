library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_controller is
	generic(
		T_BITS 				:	integer := 8
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
	signal turns, max : integer := 0;
	signal cnt : std_logic_vector(1 downto 0) := "00";
	signal dir, a_cnt1, a_cnt2, b_cnt1, b_cnt2, rst_turns, r_turns : std_logic := '0'; --0 for cw, 1 for ccw
begin
	
	process(CHANGED, FEEDBACK_A, FEEDBACK_B)
		variable r, l, x : integer := 0;
	begin
		if (rising_edge(CHANGED) and STATE = '1') then
			r := to_integer(unsigned(ANGLE)) - to_integer(unsigned(old_angle));
			l := to_integer(unsigned(old_angle)) - to_integer(unsigned(ANGLE));
			if (abs(r) < abs(l)) then x := r; else x := l; end if;
			if (x < 0) then
				--turns <= 0;
				max <= x;
				dir <= '0';
			else
				--turns <= 0;
				max <= x;
				dir <= '1';
			end if;
		end if;
		
		if (rising_edge(FEEDBACK_A)) then
			a_cnt1 <= not a_cnt1;
		elsif (falling_edge(FEEDBACK_A)) then
			a_cnt2 <= not a_cnt2;
		end if;
		
		if (rising_edge(FEEDBACK_B)) then
			b_cnt1 <= not b_cnt1;
		elsif (falling_edge(FEEDBACK_B)) then
			b_cnt2 <= not b_cnt2;
		end if;
	end process;
	
	process(a_cnt1, a_cnt2, b_cnt1, b_cnt2, rst_turns)
	begin
		if (rst_turns = not r_turns) then
			turns <= 0;
			r_turns <= not r_turns;
		elsif (((a_cnt1 = a_cnt2) and (b_cnt1 = b_cnt2)) and (b_cnt1 = a_cnt1)) then
			turns <= turns + 1;
		end if;
	end process;
	
	process(turns)
	begin
		if (turns = 0) then
			GOING <= '1';
			if (max < 0) then
				MOTOR_A <= '1'; --CW
			else
				MOTOR_B <= '1'; --CCW
			end if;
		elsif (turns = abs(max)) then
			GOING <= '0';
			MOTOR_A <= '0';
			MOTOR_B <= '0';
			rst_turns <= not rst_turns;
		else
			GOING <= '1';
		end if;
	end process;

end rtl;