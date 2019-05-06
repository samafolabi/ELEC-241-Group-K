library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_controller is
	generic(
		FIFO_DATA_WIDTH	:	integer := 12;
		SPACE_AVAIL_WIDTH	:	integer := 3;
		TX_RX_DATA_WIDTH	:	integer := 16
	);
	port(
		FIFO_CLK			:	in std_logic;
		CS					:	in std_logic;
		RX_DATA			:	in std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0);
		SPACE_AVAILABLE:	in std_logic_vector(SPACE_AVAIL_WIDTH-1 downto 0);
		FIFO_CONFIG		:	in std_logic_vector(7 downto 0);
		FIFO_DATA		:	in std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
		
		--Outputs
		TX_DATA			:	out std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0);
		ASK_FOR_READ	:	out std_logic;
		FIFO_CONFIG_OUT:	out std_logic_vector(7 downto 0);
		RST				:	out std_logic
	);
end entity;

architecture rtl of spi_controller is
signal fifo_latch : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0) := (others => '0');
signal latch_set, latch_set_2, asked_read, asked_read_fall, cmd, rst_y : std_logic := '0';
signal rst_x : std_logic := '1';
constant config_input : std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0) := "1111000000000000";
constant data_input : std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0) := "0000111100000000";
begin

	FIFO_CONFIG_OUT(6) <= '0' when SPACE_AVAILABLE = "111" else '1';
	FIFO_CONFIG_OUT(7) <= '1' when SPACE_AVAILABLE = "000" else '0';

	process(FIFO_CLK)
	begin
		if(rising_edge(FIFO_CLK)) then
			if (rst_y = rst_x) then
				rst_x <= not rst_x;
				RST <= '1';
			else
				RST <= '0';
			end if;
		
			if (asked_read = '1') then
				ASK_FOR_READ <= '0';
				asked_read <= '0';
				asked_read_fall <= '1';
			elsif (latch_set = latch_set_2) then
				if (not (SPACE_AVAILABLE = (SPACE_AVAILABLE'range => '0'))) then
					
					ASK_FOR_READ <= '1';
					asked_read <= '1';
				end if;
			else
				asked_read_fall <= '0';
			end if;
		elsif(falling_edge(FIFO_CLK)) then
			if (asked_read_fall = '1') then
				fifo_latch <= FIFO_DATA;
				latch_set <= not latch_set;
			end if;
		end if;
	end process;
	
	process(CS)
	begin
		if (falling_edge(CS)) then
			cmd <= not cmd;
		end if;
	end process;
	
	--fifo_config 7 and 6 set outside
	
	process(RX_DATA)
	begin
		if (cmd = '1') then
			if (RX_DATA = config_input) then
				TX_DATA <= "00000000" & FIFO_CONFIG;
			elsif (RX_DATA = data_input) then
				latch_set_2 <= not latch_set_2;
				TX_DATA <= "0000" & fifo_latch;
			elsif (RX_DATA(15 downto 8) = "00000000") then
				TX_DATA(15 downto 2) <= "00000000" & FIFO_CONFIG(7 downto 2);
				FIFO_CONFIG_OUT(5 downto 2) <= FIFO_CONFIG(5 downto 2);
				TX_DATA(0) <= '0';
				FIFO_CONFIG_OUT(0) <= '0';
				if(RX_DATA(0) = '1') then
					rst_y <= not rst_y;
					latch_set_2 <= not latch_set_2;
					TX_DATA(1) <= '0';
					FIFO_CONFIG_OUT(1) <= '0';
				elsif(RX_DATA(1) = '1') then --mcu can't set SAMP to 0
					TX_DATA(1) <= '1';
					FIFO_CONFIG_OUT(1) <= '1';
				else
					FIFO_CONFIG_OUT(1) <= '0';
					TX_DATA(1) <= '0';
				end if;
			elsif (RX_DATA(15 downto 8) = "11111111") then
				TX_DATA <= "0000000000000" & SPACE_AVAILABLE;
			else
				TX_DATA <= (OTHERS => 'Z');
			end if;
		end if;
	end process;

end rtl;