library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_controller is
	generic(
		channel : INTEGER := 5
	);
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
end entity;

architecture rtl of adc_controller is
	signal rising_state, falling_state : integer := -1;
	signal out_buf : std_logic_vector(10 downto 0) := (OTHERS => '0');
	signal addr : std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(channel, 3));
begin

	SCLK <= CLK;
	addr <= std_logic_vector(to_unsigned(channel, 3));
	
	process(CLK, EN)
	BEGIN
	
		IF (EN = '1') THEN
			rising_state <= -1;
			falling_state <= -1;
		ELSIF (rising_edge(CLK)) THEN
			case rising_state is
				when 0 to 14 =>
					rising_state <= rising_state + 1;
				when 15 =>
					rising_state <= -1;
				when others =>
					if (falling_state = 0) THEN
						rising_state <= 0;
					END IF;
			end case;
		ELSIF (falling_edge(CLK)) THEN
			case falling_state is
				when 0 to 14 =>
					falling_state <= falling_state + 1;
				when 15 =>
					falling_state <= -1;
				when others =>
					falling_state <= 0;
			end case;
		END IF;
	
	END process;
	
	process(rising_state, falling_state)
	BEGIN
	
		case rising_state is
			when 0 to 3 =>
				DATA_READY <= '0';
			when 4 to 14 =>
				out_buf(10-(rising_state-4)) <= ADC_IN_DATA;
				DATA_READY <= '0';
			when 15 =>
				ADC_OUT_DATA(0) <= ADC_IN_DATA;
				CS_N <= '1';
				ADC_OUT_DATA(11 downto 1) <= out_buf;
				DATA_READY <= '1';
			when others =>
				CS_N <= '1';
				DATA_READY <= '1';
		end case;
	
		case falling_state is
			when 0 =>
				CS_N <= '0';
				SADDR <= '0';
			when 2 =>
				SADDR <= addr(2);
			when 3 =>
				SADDR <= addr(1);
			when 4 =>
				SADDR <= addr(0);
			when others =>
				SADDR <= '0';
		end case;
	
	END process;

end rtl;