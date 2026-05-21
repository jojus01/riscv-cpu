library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity registers_tb is
end registers_tb;

architecture sim of registers_tb is
    component registers is
        Port (
        read_reg1, read_reg2, write_reg : in STD_LOGIC_VECTOR(4 downto 0);
        write_data : in STD_LOGIC_VECTOR(31 downto 0);
        read_data1, read_data2 : out STD_LOGIC_VECTOR(31 downto 0);
        write_enable, CLK : in STD_LOGIC
        );
    end component;

    signal write_enable : STD_LOGIC := '0';
    signal clk : STD_LOGIC := '0';
    signal read_reg1 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal read_reg2 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal write_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal read_data1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal read_data2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal write_data : STD_LOGIC_VECTOR(31 downto 0) := x"0000000A";
    signal stop : STD_LOGIC := '0';

begin
  reg: registers
   port map(
      read_reg1 => read_reg1,
      read_reg2 => read_reg2,
      write_reg => write_reg,
      write_data => write_data,
      read_data1 => read_data1,
      read_data2 => read_data2,
      write_enable => write_enable,
      CLK => CLK
  );

  clock: process
  begin
    while stop = '0' loop
      clk <= '1';
      wait for 5 ns;
      clk <= '0';
      wait for 5 ns;
    end loop;
    wait;
  end process clock;

    sim : process
    begin

      wait for 10 ns;
      for i in 0 to 15 loop
        read_reg1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i*2, 5));
        read_reg2 <= STD_LOGIC_VECTOR(TO_UNSIGNED((i*2)+1, 5));

        wait for 10 ns;

        write_reg <= read_reg1;

        wait for 6 ns;

        write_reg <= read_reg2;
      end loop;
      wait for 10 ns;

      read_reg1 <= (others => '0');
      read_reg2 <= (others => '0');
      write_reg <= (others => '0');


      wait for 10 ns;
      for i in 0 to 15 loop

        write_enable <= '1';
        write_reg <= STD_LOGIC_VECTOR(TO_UNSIGNED(i*2, 5));
        read_reg1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i*2, 5));

        wait for 5 ns;
        write_enable <= '0';
        wait for 5 ns;
        write_enable <= '1';
        write_reg <= STD_LOGIC_VECTOR(TO_UNSIGNED((i*2)+1, 5));
        read_reg2 <= STD_LOGIC_VECTOR(TO_UNSIGNED((i*2)+1, 5));
        wait for 5 ns;
        write_enable <= '0';

        wait for 5 ns;

      end loop;

      stop <= '1';

    wait;
    end process;
end sim;
