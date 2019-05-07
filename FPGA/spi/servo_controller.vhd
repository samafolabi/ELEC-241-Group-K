library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_controller is
	generic(
		M_BITS 				:	integer := 9;
		TX_RX_DATA_WIDTH	:	integer := 16
	);
	port(
		CS					:	in std_logic; --Servo Chip Select
		GOING				:	in std_logic; --Encoder running
		RX_DATA			:	in std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0); --Data received through SPI
		SERVO_REG_IN	:	in std_logic_vector(M_BITS-1 downto 0); --Input from servo register
		
		--Outputs
		TX_DATA			:	out std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0); --Data to be transmitted
		SERVO_REG_OUT	:	out std_logic_vector(M_BITS-1 downto 0); --Output to servo register
		ANG_CHANGED		:	out std_logic; --angle has changed
		SERVO_OUT		:	out std_logic_vector(M_BITS-2 downto 0); --send servo angle out
		PWM_EN			:	out std_logic --STATE in servo register and motor enable
	);
end entity;

architecture rtl of servo_controller is
	signal set_angle, set_state, cmd, changed_1, changed_2 : std_logic := '0';
begin
	
	process(CS) --specify whether cmd or data
	begin
		if (falling_edge(CS)) then
			cmd <= not cmd;
		end if;
	end process;
	
	process(GOING, changed_1)
	begin
		if (changed_1 = not changed_2) then --start motor turn process
			ANG_CHANGED <= '1';
			changed_2 <= not changed_2;
		elsif(falling_edge(GOING)) then
			ANG_CHANGED <= '0';
		end if;
	end process;
	
	process(RX_DATA)
	begin
		if (cmd = '1') then --if it is a cmd
			if (RX_DATA(TX_RX_DATA_WIDTH-1 downto TX_RX_DATA_WIDTH-3) = "11") then --get angle
				TX_DATA <= (others => '0') & SERVO_REG_IN(M_BITS-2 downto 0);
			elsif (RX_DATA(TX_RX_DATA_WIDTH-1 downto TX_RX_DATA_WIDTH-3) = "00") then --set angle
				set_angle <= '1';
			elsif (RX_DATA(TX_RX_DATA_WIDTH-1 downto TX_RX_DATA_WIDTH-3) = "01") then --get state
				TX_DATA <= (others => '0') & SERVO_REG_IN(M_BITS-1) & (others => '0');
			elsif (RX_DATA(TX_RX_DATA_WIDTH-1 downto TX_RX_DATA_WIDTH-3) = "10") then --set state
				set_state <= '1';
			else
				TX_DATA <= (OTHERS => 'Z');
			end if;
		else
			if (set_angle = '1') then --if set angle, give the servo the angle, set registers, and say it has changed
				set_angle <= '0';
				SERVO_OUT <= RX_DATA(M_BITS-2 downto 0);
				changed_1 <= not changed_1;
				SERVO_REG_OUT(M_BITS-2 downto 0) <= RX_DATA(M_BITS-2 downto 0);
			elsif (set_state = '1') then --if set state, set registers and enable/disable motors
				set_state <= '0';
				SERVO_REG_OUT(M_BITS-1) <= RX_DATA(M_BITS-1);
				PWM_EN <= RX_DATA(M_BITS-1);
			end if;
		end if;
	end process;

end rtl;