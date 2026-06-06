library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.stop;

entity data_mem_tb is
end data_mem_tb;

architecture sim of data_mem_tb is

  component data_mem is
    Port (
      clk : in  std_logic;
      write_enable : in  std_logic;
      funct3 : in  std_logic_vector(2 downto 0);
      addr : in  std_logic_vector(31 downto 0);
      write_data : in  std_logic_vector(31 downto 0);
      read_data : out std_logic_vector(31 downto 0)
    );
  end component;

  signal clk : std_logic := '0';
  signal write_enable : std_logic := '0';
  signal funct3 : std_logic_vector(2 downto 0) := "010";
  signal addr : std_logic_vector(31 downto 0) := (others => '0');
  signal write_data : std_logic_vector(31 downto 0) := (others => '0');
  signal read_data : std_logic_vector(31 downto 0);

  constant CLK_PERIOD : time := 10 ns;

  -- helper procedure: write one word
  procedure write_mem(
    signal clk : in  std_logic;
    signal write_enable : out std_logic;
    signal funct3_s : out std_logic_vector(2 downto 0);
    signal addr_s : out std_logic_vector(31 downto 0);
    signal wdata : out std_logic_vector(31 downto 0);
    constant f3 : in  std_logic_vector(2 downto 0);
    constant a : in  std_logic_vector(31 downto 0);
    constant d : in  std_logic_vector(31 downto 0)
  ) is
  begin
    funct3_s <= f3;
    addr_s <= a;
    wdata <= d;
    write_enable <= '1';
    wait until rising_edge(clk);
    write_enable <= '0';
    wait for 1 ns;  -- small delta delay for read_data to settle
  end procedure;

begin

  dmem : data_mem
    port map (
      clk => clk,
      write_enable  => write_enable,
      funct3 => funct3,
      addr => addr,
      write_data => write_data,
      read_data => read_data
    );

  -- clock generator
  clk <= not clk after CLK_PERIOD / 2;

  sim : process
  begin

    -- Test 1: SW + LW
    -- write 0xDEADBEEF to address 0x00
    write_mem(clk, write_enable, funct3, addr, write_data, "010", x"00000000", x"DEADBEEF");
    funct3 <= "010";
    addr   <= x"00000000";
    wait for 1 ns;
    assert read_data = x"DEADBEEF"
        report "FAIL: SW+LW" severity error;
    report "PASS: SW+LW";

    -- Test 2: SB + LB (sign extension)
    -- write 0xFF to byte address 0x00 (byte 0 of word 0)
    write_mem(clk, write_enable, funct3, addr, write_data, "000", x"00000000", x"000000FF");
    funct3 <= "000";  -- LB
    addr   <= x"00000000";
    wait for 1 ns;
    assert read_data = x"FFFFFFFF"
        report "FAIL: SB+LB sign extension" severity error;
    report "PASS: SB+LB sign extension";

    -- Test 3: LBU (zero extension, same byte)
    funct3 <= "100";  -- LBU
    addr <= x"00000000";
    wait for 1 ns;
    assert read_data = x"000000FF"
        report "FAIL: LBU zero extension" severity error;
    report "PASS: LBU zero extension";

    -- Test 4: SB isolation
    -- write 0xAA to byte address 0x01 (byte 1 of word 0)
    -- byte 0 must still be 0xFF from Test 2
    write_mem(clk, write_enable, funct3, addr, write_data, "000", x"00000001", x"000000AA");
    funct3 <= "010";  -- LW - read full word
    addr <= x"00000000";
    wait for 1 ns;
    -- byte0=0xFF, byte1=0xAA, byte2 and byte3 from test 1
    assert read_data(7  downto 0)  = x"FF"
        report "FAIL: SB isolation - byte 0 changed" severity error;
    assert read_data(15 downto 8)  = x"AA"
        report "FAIL: SB isolation - byte 1 wrong" severity error;
    report "PASS: SB isolation";

    -- Test 5: SH + LH (sign extension)
    -- write 0x8000 to halfword address 0x02 (upper halfword of word 0)
    write_mem(clk, write_enable, funct3, addr, write_data, "001", x"00000002", x"00008000");
    funct3 <= "001";  -- LH
    addr <= x"00000002";
    wait for 1 ns;
    assert read_data = x"FFFF8000"
        report "FAIL: SH+LH sign extension" severity error;
    report "PASS: SH+LH sign extension";

    -- Test 6: LHU (zero extension, same halfword)
    funct3 <= "101";  -- LHU
    addr   <= x"00000002";
    wait for 1 ns;
    assert read_data = x"00008000"
        report "FAIL: LHU zero extension" severity error;
    report "PASS: LHU zero extension";

    -- Test 7: SW to different address
    write_mem(clk, write_enable, funct3, addr, write_data, "010", x"00000004", x"12345678");
    funct3 <= "010";
    addr <= x"00000004";
    wait for 1 ns;
    assert read_data = x"12345678"
        report "FAIL: SW to different address" severity error;
    report "PASS: SW to different address";

    -- make sure word 0 is unchanged
    addr <= x"00000000";
    wait for 1 ns;
    assert read_data /= x"12345678"
        report "FAIL: word 0 was overwritten" severity error;
    report "PASS: word independence";

    report "ALL TESTS DONE"; 
    stop;
end process;

end sim;
