library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder is
    Port (
        A   : in  STD_LOGIC_VECTOR(31 downto 0);
        B   : in  STD_LOGIC_VECTOR(31 downto 0);
        RES : out STD_LOGIC_VECTOR(31 downto 0)
    );
end adder;

architecture Behavioral of adder is
begin

    RES <= STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
end Behavioral;
