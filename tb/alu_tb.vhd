library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
end alu_tb;

architecture sim of alu_tb is
    component alu is
        Port(
          A,B : in STD_LOGIC_VECTOR(31 downto 0);
          RES : out STD_LOGIC_VECTOR(31 downto 0);
          OP : in STD_LOGIC_VECTOR(3 downto 0);
          STAT_0 : out STD_LOGIC
        );
    end component;

    signal A : STD_LOGIC_VECTOR(31 downto 0);
    signal B : STD_LOGIC_VECTOR(31 downto 0);
    signal result : STD_LOGIC_VECTOR(31 downto 0);
    signal operation : STD_LOGIC_VECTOR(3 downto 0);
    signal stat : STD_LOGIC;

begin
  alu_inst: alu
   port map(
      A => A,
      B => B,
      RES => result,
      OP => operation,
      STAT_0 => stat
  );



  sim : process
    procedure check(
      op_in : STD_LOGIC_VECTOR(3 downto 0);
      a_in : STD_LOGIC_VECTOR(31 downto 0);
      b_in : STD_LOGIC_VECTOR(31 downto 0);
      exp : STD_LOGIC_VECTOR(31 downto 0);
      name : string) is
    begin
      operation <= op_in;
      A <= a_in;
      B <= b_in;
      wait for 10 ns;
      assert result = exp report name & "failed" severity Error;
    end procedure check;

    begin
      check("0000", x"00000007", x"00000003", x"0000000A", "ADD");
      check("1000", x"0000000F", x"0000000A", x"00000005", "SUB");
      check("0100", x"10101010", x"10010010", x"00111000", "XOR");
      check("0110", x"01020307", x"00000003", x"01020307", "OR");
      check("0111", x"00000007", x"00000003", x"00000003", "AND");
      check("0001", x"00000007", x"00000002", x"0000001C", "SLL");
      check("0101", x"00000010", x"00000001", x"00000008", "SRL");
      check("1101", x"FFFFFFF8", x"00000001", x"FFFFFFFC", "SRA");
      check("0010", x"00000007", x"000000FF", x"00000001", "SLT_True");
      check("0010", x"0000000F", x"0000000A", x"00000000", "SLT_False");
      check("0010", x"FFFFFFFF", x"00000003", x"00000001", "SLT_negative");
      check("0011", x"00000007", x"0000000A", x"00000001", "SLTU_True");
      check("0011", x"00000007", x"00000003", x"00000000", "SLTU_False");

      report "all tests passed!";

        wait;
  end process;
end sim;
