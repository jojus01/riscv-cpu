library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registers is
    Port (
           read_reg1 : in STD_LOGIC_VECTOR(4 downto 0);      -- uses the adress with a lenght of 5 bits to select one of 32 registers that can be read.
    read_reg2 : in STD_LOGIC_VECTOR(4 downto 0);
    write_reg : in STD_LOGIC_VECTOR(4 downto 0);            -- select the register that can be written.
    write_data : in STD_LOGIC_VECTOR(31 downto 0);
    read_data1 : out STD_LOGIC_VECTOR(31 downto 0);         -- data ouput for alu operation. the right register can be selected via adress on read_reg.
    read_data2 : out STD_LOGIC_VECTOR(31 downto 0);
    write_enable : in STD_LOGIC;                            -- must be set to HIGH to write a value on a register except register x0.
    CLK : in STD_LOGIC
    );
end registers;

architecture Behavioral of registers is
  type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);   -- Settig up a registerbank with 32 registers and 32 bits each.
  signal regs : reg_array := (others => (others => '0')); -- initial values

begin

  write_synchronus: process(CLK)                                  -- writing data in a register. operation runs synchronous with a clock signal
  begin
    if rising_edge(CLK) then
      if write_enable = '1' and write_reg /= "00000" then         -- registers can only be written, when write_enable is high and the selected register
        regs(TO_INTEGER(unsigned(write_reg))) <= write_data;      -- is not x0 
      end if;                                                     -- register x0 always hold a value of 0 and can not be overwritte                     
    end if;
  end process write_synchronus;

  read_data1 <= (others => '0') when read_reg1 = "00000"          -- asynchronous reading of registers
                else regs(TO_INTEGER(unsigned(read_reg1)));

  read_data2 <= (others => '0') when read_reg2 = "00000" 
                else regs(TO_INTEGER(unsigned(read_reg2)));

end Behavioral;
