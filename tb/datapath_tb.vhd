library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.STOP;

entity datapath_tb is
end datapath_tb;

architecture sim of datapath_tb is

    component datapath is
        Port (
            clk   : in STD_LOGIC;
            reset : in STD_LOGIC;
            LED : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';

    constant CLK_PERIOD : time := 15 ns;

begin

    rv32i : datapath
        port map (clk => clk, reset => reset);

    clk <= not clk after CLK_PERIOD / 2;

    sim : process
    begin
      wait for CLK_PERIOD * 1000;
      stop;
    end process;

end sim;
