library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc_tb is
end pc_tb;

architecture sim of pc_tb is
    component pc is
        Port (
        CLK,RST,PC_write : in STD_LOGIC;
        PC_in : in STD_LOGIC_VECTOR(31 downto 0);
        PC_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    signal clk : STD_LOGIC;
    signal rst : STD_LOGIC := '0';
    signal pc_write : STD_LOGIC := '0';
    signal pc_in : STD_LOGIC_VECTOR(31 downto 0) := x"ff00ff11";
    signal pc_out : STD_LOGIC_VECTOR(31 downto 0);
    signal stop : STD_LOGIC := '0';
begin
  programmcounter: pc
   port map(
      CLK => CLK,
      RST => RST,
      PC_write => PC_write,
      PC_in => PC_in,
      PC_out => PC_out
  );

  clock: process
  begin
    while stop = '0' loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
    wait;
  end process clock;


    sim : process
    begin
      wait for 150 ns;
      rst <= '1';
      wait for 10 ns;
      rst <= '0';
      wait for 50 ns;
      pc_write <= '1';
      wait for 20 ns;
      pc_write <= '0';
      wait for 40 ns;
      stop <= '1';
        wait;
    end process;
end sim;
