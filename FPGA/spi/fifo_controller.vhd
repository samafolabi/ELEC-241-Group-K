library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_controller is
	generic(
		DATA_WIDTH	: INTEGER	:= 12;
		USED_WORDS	: INTEGER	:= 3;
	);
	port(
		CLK			:	in std_logic;
		CLR			:	in std_logic; --request to clear the fifo
		DATA_WRITE	:	in std_logic_vector(DATA_WIDTH-1 downto 0); --data to write into the fifo
		DATA_READ	:	in std_logic_vector(DATA_WIDTH-1 downto 0); --data read from the fifo
		FULL			:	in std_logic; --fifo is full
		EMPTY			:	in std_logic; --fifo is empty
		WORDS_USED	:	in std_logic_vector(USED_WORDS-1 downto 0); --number of words used in fifo
		
		SCLK			:	out std_logic; --fifo output clock
		FIFO_WRITE	:	out std_logic_vector(DATA_WIDTH-1 downto 0); --data to be written to the fifo
		FIFO_READ	:	out std_logic_vector(DATA_WIDTH-1 downto 0); --data read from the fifo
		FIFO_CLR		:	out std_logic; --clear the fifo
		WRITE_REQ	:	out std_logic; --tell the fifo to write data
		READ_REQ		:	out std_logic  --tell the fifo you want to read data
	);
end entity;

architecture rtl of fifo_controller is
	
begin

	

end rtl;