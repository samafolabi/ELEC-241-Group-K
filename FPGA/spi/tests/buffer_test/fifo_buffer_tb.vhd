library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity fifo_buffer_test is
end fifo_buffer_test;

architecture v1 of fifo_buffer_test is
signal CLK: std_logic;
signal X: std_logic;
signal Y: std_logic;

component 
	port(
		data[LPM_WIDTH-1..0]		: input;
	q[LPM_WIDTH-1..0]			: output;

	wrreq, rdreq				: input;
	clock						: input;
	aclr, sclr					: input = gnd;

    eccstatus[1..0]             :output;

	empty, full					: output;
	almost_full, almost_empty	: output;
	usedw[WIDTHAD-1..0]			: output;
	);
end component;

begin
	u1 : SCFIFO port map (
		CLK => CLK,
		X => X,
		Y => Y
	);
	
	main : process
	begin
		
		
		
	wait;
	end process main;
END v1;
