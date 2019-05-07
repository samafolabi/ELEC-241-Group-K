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
		CS					:	in std_logic; --SPI Chip Select
		RX_DATA			:	in std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0); --Data received from the MCU
		SPACE_AVAILABLE:	in std_logic_vector(SPACE_AVAIL_WIDTH-1 downto 0); --Space available in FIFO buffer
		FIFO_CONFIG		:	in std_logic_vector(7 downto 0); --FIFO_CONFIG value
		FIFO_DATA		:	in std_logic_vector(FIFO_DATA_WIDTH-1 downto 0); --Current FIFO buffer value
		FULL				:	in std_logic; --Indicator if FIFO buffer is full
		RX_REQ			:	in std_logic; --Indicator if a receive request was given
		
		--Outputs
		TX_DATA			:	out std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0); --Data transmitted to the MCU
		ASK_FOR_READ	:	out std_logic; --Ask to read from FIFO buffer
		FIFO_CONFIG_OUT:	out std_logic_vector(7 downto 0); --Output to change FIFO_CONFIG
		RST				:	out std_logic --Reset FIFO buffer
	);
end entity;

architecture rtl of spi_controller is
signal fifo_latch : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0) := (others => '0');
signal latch_set, latch_set_2, asked_read, asked_read_fall, cmd, rst_y : std_logic := '0';
signal rst_x : std_logic := '1';

constant config_input : std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0) := "1111000000000000";
constant data_input : std_logic_vector(TX_RX_DATA_WIDTH-1 downto 0) := "0000111100000000";
begin

	--it's the opposite of space available, its actually the number of words used
	--always permanently set this way
	FIFO_CONFIG_OUT(6) <= '0' when SPACE_AVAILABLE = "000" else '1';--avail
	FIFO_CONFIG_OUT(7) <= '1' when SPACE_AVAILABLE = "111" and FULL = '1' else '0';--overflow

	process(FIFO_CLK)
	begin
		if(rising_edge(FIFO_CLK)) then
			if (rst_y = rst_x) then --reset logic
				rst_x <= not rst_x;
				RST <= '1';
			else
				RST <= '0';
			end if;
		
			if (asked_read = '1') then --if the latch is not set (equal to latch_set_2) and the buffer is not empty
				ASK_FOR_READ <= '0';		--then read from the buffer on the falling edge and latch it
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
	
	--determine if cmd or write
	process(CS)
	begin
		if (falling_edge(CS)) then
			cmd <= not cmd;
		end if;
	end process;
	
	
	
	process(RX_REQ)
	begin
		if (cmd = '1' and RX_REQ = '1') then --if it is a cmd and the rx_data is ready
		
			if (RX_DATA = config_input) then --send the FIFO_CONFIG reg
				TX_DATA(15 downto 0) <= "00000000" & FIFO_CONFIG(7 downto 0);
				
			elsif (RX_DATA = data_input) then --send the latched data and unlatch it
				latch_set_2 <= not latch_set_2;
				TX_DATA <= "0000" & fifo_latch;
				
			elsif (RX_DATA(15 downto 8) = "00000000") then --new FIFO_CONFIG data incoming
				TX_DATA(15 downto 2) <= "00000000" & FIFO_CONFIG(7 downto 2); --set TX data
				FIFO_CONFIG_OUT(5 downto 2) <= FIFO_CONFIG(5 downto 2);--set FIFO_CONFIG reg
				
				TX_DATA(0) <= '0'; --make sure reset is not saved
				FIFO_CONFIG_OUT(0) <= '0';
				
				if(RX_DATA(0) = '1') then --if reset was set, start reset logic and turn samp off
					rst_y <= not rst_y;
					latch_set_2 <= not latch_set_2;
					TX_DATA(1) <= '0';
					FIFO_CONFIG_OUT(1) <= '0';
				elsif(RX_DATA(1) = '1') then --if samp was set, send it out
					TX_DATA(1) <= '1';
					FIFO_CONFIG_OUT(1) <= '1';
				else --make sure the mcu can't change the value
					FIFO_CONFIG_OUT(1) <= '1';
					TX_DATA(1) <= '1';
				end if;
				
			elsif (RX_DATA(15 downto 8) = "11111111") then --send the space available in the FIFO buffer
				TX_DATA <= "0000000000000" & SPACE_AVAILABLE;
				
			else
				TX_DATA <= (OTHERS => 'Z');
			end if;
		end if;
	end process;

end rtl;