library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity regn_test is
end regn_test;

architecture v1 of regn_test is
constant DATA_WIDTH : natural := 16;
constant T_CLK : time := 20 ns;
constant T_END : time := 500 ns;

signal datain, dataout: std_logic_vector(DATA_WIDTH-1 downto 0);
signal clk, load, reset, oe: std_logic := '0';

procedure wait_fall is
begin
	wait until (CLK'DELAYED(1 ps)'EVENT and CLK = '0');
end wait_fall;

procedure wait_rise is
begin
	wait until (CLK'DELAYED(1 ps)'EVENT and CLK = '1');
end wait_rise;

procedure confirm(expected : std_logic_vector(DATA_WIDTH-1 downto 0)) is
begin
	assert(dataout = expected)
		report "DATAOUT is not equal to the expected data"
		severity error;
end confirm;

component program_counter_reg
	generic (
		W : natural := 16
	);

	port (
		clk     : in    std_logic;      --Clock
      load    : in    std_logic;      --Clock enable
      reset   : in    std_logic;      --Async reset
      datain  : in    std_logic_vector(W-1 downto 0);	
		OE      : in    std_logic;			--Output enable
      dataout : out   std_logic_vector(W-1 downto 0)
	);
end component;

begin
	u1 : program_counter_reg
	generic map (
		W => DATA_WIDTH
	)
	port map (
		clk, load, reset, datain, oe, dataout
	);
	
	clock : process
		variable t : time := 0 ns;
	begin
		loop
			t := t + T_CLK;
			wait for T_CLK;
			clk <= not clk;
			exit when t >= T_END;
		end loop;
		wait;
	end process clock;
	
	main : process
	begin
		
		load <= '0';
		oe <= '0';
		reset <= '0';
		
		wait_fall;
		reset <= '1';
		datain <= (others => '1');
		wait_rise;
		confirm("00000000");
		
		wait_fall;
		oe <= '1';
		datain <= (others => '1');
		wait_rise;
		confirm("11111111");
		
		wait_fall;
		load <= '1';
		datain <= (others => '1');
		wait_rise;
		confirm("11111111");
		
		wait_fall;
		load <= '0';
		datain <= (others => '0');
		wait_rise;
		confirm("00000000");
		
		reset <= '0';
		wait_fall;
		load <= '1';
		wait_rise;
		confirm("00000000");
		
	wait;
	end process main;
END v1;
