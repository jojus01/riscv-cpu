library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux is
    Port (
    in_0 : in STD_LOGIC_VECTOR(31 downto 0);
    in_1 : in STD_LOGIC_VECTOR(31 downto 0);
    mux_out : out STD_LOGIC_VECTOR(31 downto 0);
    mux_sel : in STD_LOGIC
    );
end mux;

architecture Behavioral of mux is
begin
  multiplexer: process(mux_sel, in_1, in_0)
  begin
    if mux_sel = '1' then
      mux_out <= in_1;
    else 
      mux_out <= in_0;
    end if;
    
  end process multiplexer;
end Behavioral;
