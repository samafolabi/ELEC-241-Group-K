library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity fifo_controller_test is
end fifo_controller_test;

architecture v1 of fifo_controller_test is

constant DATA_WIDTH	: INTEGER	:= 12;
constant USED_WORDS	: INTEGER	:= 3;
constant T_CLK : time := 10 ns;
constant T_END : time := 1000 ns;

signal CLK,CLR,FULL,EMPTY,READ_REQ,WRITE_REQ,SCLK,FIFO_CLR,FIFO_WRITE_REQ,FIFO_READ_REQ : std_logic := '0';
signal DATA_WRITE,DATA_READ,FIFO_WRITE,FIFO_READ : std_logic_vector(DATA_WIDTH-1 downto 0);
signal WORDS_USED, SPACE_AVAILABLE : std_logic_vector(USED_WORDS-1 downto 0);

signal increment : integer := 0;

procedure wait_fall is
begin
	wait until (CLK'EVENT and CLK = '0');
end wait_fall;

procedure wait_rise is
begin
	wait until (CLK'EVENT and CLK = '1');
end wait_rise;

component fifo_controller
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
		SPACE_AVAILABLE:	out std_logic_vector(USED_WORDS-1 downto 0)
	);
end component;

begin
	u1 : fifo_controller port map (
		CLK,CLR,DATA_WRITE,DATA_READ,FULL,EMPTY,WORDS_USED,READ_REQ,WRITE_REQ,SCLK,FIFO_WRITE,FIFO_READ,FIFO_CLR,FIFO_WRITE_REQ,FIFO_READ_REQ,SPACE_AVAILABLE
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
	
	inc : process
	begin
		loop
			wait_rise;
			if (increment = 15) then increment <= 0; else increment <= increment + 1; end if;
		end loop;
	end process inc;
	
	main : process
	begin
		
		wait_rise;
		EMPTY <= '1';
		wait_rise;
		--DATA_WRITE <= increment;
		wait_fall;
		WRITE_REQ <= '1';
		wait_rise;
		EMPTY <= '0';
		wait_rise;
		wait_rise;
		wait_rise;
		wait_rise;
		
	wait;
	end process main;
END v1;
