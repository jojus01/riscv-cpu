-- Programm Counter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc is
    Port (
    CLK : in STD_LOGIC; 
    RST : in STD_LOGIC;         -- reset. if it turns high pc out returns to start address
    PC_in : in STD_LOGIC_VECTOR(31 downto 0); -- target address input for jumps
    PC_out : out STD_LOGIC_VECTOR(31 downto 0) -- address output 
    );
end pc;


architecture Behavioral of pc is
  signal pc_reg : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
begin
  PC_out <= pc_reg;

  prg_counter: process(clk, rst)
  begin
    if rst = '1' then
      pc_reg <= x"00000000";    -- start address
    elsif rising_edge(clk) then
      pc_reg <= PC_in;
    end if;
  end process prg_counter;
end Behavioral;
