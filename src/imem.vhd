-- Instruction Memory 
-- 16kB storage

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imem is
    Port (
    CLK : in STD_LOGIC;
    ADDR : in STD_LOGIC_VECTOR(31 downto 0);
    DATA : out STD_LOGIC_VECTOR(31 downto 0)
    );
end imem;

architecture Behavioral of imem is
  type mem_array is array (0 to 4095) of STD_LOGIC_VECTOR(31 downto 0);

  signal memory : mem_array := (others => x"00000013"); -- nop 

begin
  read_mem: process(clk)
  begin
    if rising_edge(clk) then
      data <= memory(TO_INTEGER(unsigned(ADDR(13 downto 2))));
    end if;
  end process read_mem;
end Behavioral;
