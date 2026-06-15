library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imem is
    Port (
        CLK  : in  STD_LOGIC;
        ADDR : in  STD_LOGIC_VECTOR(31 downto 0);
        DATA : out STD_LOGIC_VECTOR(31 downto 0)
    );
end imem;

architecture Behavioral of imem is
    type mem_array is array(0 to 4095) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : mem_array := (
        0     => x"00100093",  -- addi x1, x0, 1
        1     => x"00B001B7",  -- lui  x3, 2816
        2     => x"0010C093",  -- xori x1, x1, 1
        3     => x"00008393",  -- addi x7, x1, 0
        4     => x"00000113",  -- addi x2, x0, 0
        5     => x"00110113",  -- addi x2, x2, 1
        6     => x"FE311EE3",  -- bne  x2, x3, -4
        7     => x"FEDFF06F",  -- jal  x0, -20
        others => x"00000013"  -- NOP (addi x0, x0, 0)
    );
    attribute ram_style : string;
    attribute ram_style of memory : signal is "block";

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            DATA <= memory(to_integer(unsigned(ADDR(13 downto 2))));
        end if;
    end process;
end Behavioral;

