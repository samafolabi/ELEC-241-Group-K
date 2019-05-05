library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_controller is
	generic(
		DATA_WIDTH	: INTEGER	:= 12;
		USED_WORDS	: INTEGER	:= 3
	);
	port(
		CLK				:	in std_logic;
		CLR				:	in std_logic; --request to clear the fifo
		DATA_WRITE		:	in std_logic_vector(DATA_WIDTH-1 downto 0); --data to write into the fifo
		DATA_READ		:	in std_logic_vector(DATA_WIDTH-1 downto 0); --data read from the fifo
		FULL				:	in std_logic; --fifo is full
		EMPTY				:	in std_logic; --fifo is empty
		WORDS_USED		:	in std_logic_vector(USED_WORDS-1 downto 0); --number of words used in fifo
		READ_REQ			:	in std_logic; --data needs to be read
		WRITE_REQ		:	in std_logic; --data needs to be written
		
		SCLK				:	out std_logic; --fifo output clock
		FIFO_WRITE		:	out std_logic_vector(DATA_WIDTH-1 downto 0); --data to be written to the fifo
		FIFO_READ		:	out std_logic_vector(DATA_WIDTH-1 downto 0); --data read from the fifo
		FIFO_CLR			:	out std_logic; --clear the fifo
		FIFO_WRITE_REQ	:	out std_logic; --tell the fifo to write data
		FIFO_READ_REQ	:	out std_logic;  --tell the fifo you want to read data
		SPACE_AVAILABLE:	out std_logic_vector(USED_WORDS-1 downto 0) --number of words used in fifo
	);
end entity;

architecture rtl of fifo_controller is
	signal clear_fifo : std_logic := '0';
begin

	SCLK <= CLK;
	FIFO_WRITE <= DATA_WRITE;
	FIFO_READ <= DATA_READ;
	SPACE_AVAILABLE <= WORDS_USED;
	
	--writes and reads are on rising edge from fifo perspective,
	--so fifo controller changes any important data on falling edge.
	--give the inputs on rising edge
	process (CLK)
	begin
	
		if (falling_edge(CLK)) then
		
			if (CLR = '1') then --if CLR is active, it will set FIFO_CLR for as many clock cycles as it is active
				FIFO_CLR <= '1';
			else
				FIFO_CLR <= '0';
				if (FULL = '1' or WRITE_REQ = '0') then
					FIFO_WRITE_REQ <= '0';--enable write to fifo when it is not full and there is data to write
				else
					FIFO_WRITE_REQ <= '1';
				end if;
				
				if (EMPTY = '1' or READ_REQ = '0') then
					FIFO_READ_REQ <= '0';--enable read from fifo when it is not empty and data needs to be read
				else
					FIFO_READ_REQ <= '1';
				end if;		
			end if;
		
		end if;
	
	end process;
	

end rtl;