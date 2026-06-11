#!/usr/bin/env python3
import sys
lines = open(sys.argv[1] if len(sys.argv) > 1 else "programm.hex").read().strip().split('\n')
init = "\n".join(f"        {i:<5} => x\"{l.upper()}\"," for i, l in enumerate(lines))
print(f"""library IEEE;
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
{init}
        others => x"00000013"
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
""")
