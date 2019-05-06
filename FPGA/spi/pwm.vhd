library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pwm_reg_pack.ALL;
 
entity pwm is 
  generic(
 SYS_CLK    	     : natural := 50_000;		-- System clock in kHz
 PWM_CLK  	     : natural := 250;			-- PWM clock in kHz
 DUTY_CYCLE_W      : natural := 5;			-- PWM resolution in bits
PERIOD            : natural := SYS_CLK / (PWM_CLK * 2**DUTY_CYCLE_W);
 PERIOD_W	     : natural := integer(ceil(log2(real(PERIOD+1))));
 
    duty     : std_logic_vector(DUTY_CYCLE_W-1 downto 0) := "11100";
  );
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
 
    -- signals from top module to registers sub-module
    en       : in std_logic;		
    pwm_out  : out std_logic
  );
end entity pwm;
 
architecture rtl of pwm is
  signal clk_en    : std_logic;
  signal cnt       : unsigned(PERIOD_W-1 downto 0);
  signal cnt_duty  : unsigned(DUTY_CYCLE_W-1 downto 0);
 
begin
  cnt_pr : process(clk, rst)
  begin 
    if (rst = '1') then
      cnt     <= (others => '0');
      clk_en  <= '0';
    elsif (rising_edge(clk)) then
      -- default
      clk_en  <= '0';
 
      if (en = '1') then
        if (cnt = 0) then
          cnt     <= to_unsigned(PERIOD-1, cnt'length);
          clk_en	<= '1';
        else
          cnt <= cnt - 1;
        end if;
      end if;	
    end if;	
  end process cnt_pr;	
 
  cnt_duty_pr : process(clk, rst)
  begin 
    if (rst = '1') then
      cnt_duty    <= (others => '0');
      pwm_out     <= '0';
    elsif (rising_edge(clk)) then		
      if (clk_en = '1') then
        cnt_duty <= cnt_duty + 1;
      end if;	
      if (cnt_duty < unsigned(duty)) then
	pwm_out <= '1';
      else
	pwm_out <= '0';
      end if;		
    end if;	
  end process cnt_duty_pr;	
 
end rtl;