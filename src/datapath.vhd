library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    Port (
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    LED : out STD_LOGIC_VECTOR(15 downto 0)
    );
end datapath;

architecture Behavioral of datapath is 

  component pc is
    Port(
    CLK,RST,PC_write : in STD_LOGIC;
    PC_in : in STD_LOGIC_VECTOR(31 downto 0);
    PC_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
  end component;

  component imem is 
    Port(
    CLK : in STD_LOGIC;
    ADDR : STD_LOGIC_VECTOR(31 downto 0);
    DATA : out STD_LOGIC_VECTOR(31 downto 0)
        );
  end component;

  component decoder is 
    Port(
    INST : in STD_LOGIC_VECTOR(31 downto 0);
    rs1, rs2, rd : out STD_LOGIC_VECTOR(4 downto 0);
    imm : out STD_LOGIC_VECTOR(31 downto 0);
    alu_op : out STD_LOGIC_VECTOR(3 downto 0);
    funct3 : out STD_LOGIC_VECTOR(2 downto 0);
    alu_src, write_reg, read_mem, write_mem,
    mem_to_reg, branch, pc_src, jalr : out STD_LOGIC
        );
  end component;

  component registers is 
    Port(
    CLK : in STD_LOGIC;
    read_reg1, read_reg2, write_reg : in STD_LOGIC_VECTOR(4 downto 0);
    write_data : in STD_LOGIC_VECTOR(31 downto 0);
    read_data1, read_data2 : out STD_LOGIC_VECTOR(31 downto 0);
    write_enable : in STD_LOGIC
        );
  end component;

  component mux is 
    Port(
    in_0, in_1 : in STD_LOGIC_VECTOR(31 downto 0);
    mux_out : out STD_LOGIC_VECTOR(31 downto 0);
    mux_sel : in STD_LOGIC
        );
  end component;

  component alu is 
    Port(
    A,B : in STD_LOGIC_VECTOR(31 downto 0);
    OP : in STD_LOGIC_VECTOR(3 downto 0);
    RES : out STD_LOGIC_VECTOR(31 downto 0);
    STAT_0 : out STD_LOGIC
        );
  end component;

  component data_mem is 
    Port(
    CLK,write_enable : in STD_LOGIC;
    funct3 : in STD_LOGIC_VECTOR(2 downto 0);
    addr,write_data : in STD_LOGIC_VECTOR(31 downto 0);
    read_data : out STD_LOGIC_VECTOR(31 downto 0)
        );
  end component;

  signal pc_imem : STD_LOGIC_VECTOR(31 downto 0);
  signal imem_decode : STD_LOGIC_VECTOR(31 downto 0);
  signal PC_in : STD_LOGIC_VECTOR(31 downto 0);
  signal rs1 : STD_LOGIC_VECTOR(4 downto 0);
  signal rs2 : STD_LOGIC_VECTOR(4 downto 0);
  signal rd : STD_LOGIC_VECTOR(4 downto 0);
  signal imm : STD_LOGIC_VECTOR(31 downto 0);
  signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
  signal funct3 : STD_LOGIC_VECTOR(2 downto 0);
  signal alu_src_en : STD_LOGIC;
  signal write_reg : STD_LOGIC;
  signal read_mem : STD_LOGIC;
  signal write_mem : STD_LOGIC;
  signal mem_to_reg : STD_LOGIC;
  signal branch : STD_LOGIC;
  signal pc_src : STD_LOGIC;
  signal rs1_alu : STD_LOGIC_VECTOR(31 downto 0);
  signal rs2_alu : STD_LOGIC_VECTOR(31 downto 0);
  signal alu_src_out : STD_LOGIC_VECTOR(31 downto 0);
  signal not_connected : STD_LOGIC;
  signal branch_stat : STD_LOGIC;
  signal ALU_0_res : STD_LOGIC_VECTOR(31 downto 0);
  signal mem_to_reg_data : STD_LOGIC_VECTOR(31 downto 0);
  signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0);
  signal pc_ex : STD_LOGIC_VECTOR(31 downto 0);
  signal inst_ex : STD_LOGIC_VECTOR(31 downto 0);
  signal flush : STD_LOGIC;
  signal pc_src_jump : STD_LOGIC;
  signal jalr : STD_LOGIC;
  signal pc_alu_sel : STD_LOGIC_VECTOR(31 downto 0);
  signal led_reg : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  signal take_branch : STD_LOGIC;

begin

  programm_counter: pc
   port map(
      CLK => CLK,
      RST => reset,
      PC_write => pc_src,
      PC_in => PC_in,
      PC_out => pc_imem
  );

  PC_ALU: alu
   port map(
      A => pc_alu_sel,
      B => imm,
      OP => "0000",
      RES => PC_in,
      STAT_0 => not_connected
  );

  instruction_memory: imem
   port map(
      CLK => CLK,
      ADDR => pc_imem,
      DATA => imem_decode
  );

  decoder_inst: decoder
   port map(
      INST => inst_ex,
      rs1 => rs1,
      rs2 => rs2,
      rd => rd,
      imm => imm,
      alu_op => alu_op,
      funct3 => funct3,
      alu_src => alu_src_en,
      write_reg => write_reg,
      read_mem => read_mem,
      write_mem => write_mem,
      mem_to_reg => mem_to_reg,
      branch => branch,
      pc_src => pc_src_jump,
      jalr => jalr
  );

  Regs: registers
   port map(
      read_reg1 => rs1,
      read_reg2 => rs2,
      write_reg => rd,
      write_data => mem_to_reg_data,
      read_data1 => rs1_alu,
      read_data2 => rs2_alu,
      write_enable => write_reg,
      CLK => CLK
  );

  src_alu: mux
   port map(
      in_0 => rs2_alu,
      in_1 => imm,
      mux_out => alu_src_out,
      mux_sel => alu_src_en
  );

  ALU_0: alu
   port map(
      A => rs1_alu,
      B => alu_src_out,
      OP => alu_op,
      RES => ALU_0_res,
      STAT_0 => branch_stat
  );

  data_memory: data_mem
   port map(
      CLK => CLK,
      write_enable => write_mem,
      funct3 => funct3,
      addr => ALU_0_res,
      write_data => rs2_alu,
      read_data => mem_read_data
  );

  mem_mux: mux
   port map(
      in_0 => ALU_0_res,
      in_1 => mem_read_data,
      mux_out => mem_to_reg_data,
      mux_sel => mem_to_reg
  );

  -- Branch logic 
  branch_evaluator: process(branch, funct3, rs1_alu, rs2_alu)
  begin
    take_branch <= '0';

    if branch = '1' then
      case funct3 is
        when "000" => -- BEQ (Branch if Equal)
          if rs1_alu = rs2_alu then 
            take_branch <= '1'; 
          end if;
            
        when "001" => -- BNE (Branch if Not Equal)
          if rs1_alu /= rs2_alu then 
            take_branch <= '1'; 
          end if;
          
        when "100" => -- BLT (Branch Less Than)
          if signed(rs1_alu) < signed(rs2_alu) then 
            take_branch <= '1';
          end if;
            
        when "101" => -- BGE (Branch Greater Equal)
          if signed(rs1_alu) >= signed(rs2_alu) then 
            take_branch <= '1'; 
          end if;
            
        when "110" => -- BLTU (Branch Less Than)
          if unsigned(rs1_alu) < unsigned(rs2_alu) then 
            take_branch <= '1'; 
          end if;
          
        when "111" => -- BGEU (Branch Greater Equal)
          if unsigned(rs1_alu) >= unsigned(rs2_alu) then 
            take_branch <= '1'; 
          end if;
            
        when others =>
          take_branch <= '0';
      end case;
    end if;
  end process;

  pc_src <= take_branch or pc_src_jump;

  -- Fetch Pipeline
  pipeline_reg: process(clk, reset)
  begin
    if reset = '1' then
      pc_ex <= (others => '0');
      flush <= '1';
    elsif rising_edge(clk) then 
      pc_ex <= pc_imem;
      flush <= pc_src;
    end if;
  end process pipeline_reg;

  inst_ex <= x"00000013" when flush = '1' else imem_decode;

  -- mux: pc_ex for JAL, rs1 for JALR
  pc_alu_sel <= rs1_alu when jalr = '1' else pc_ex;
  
  -- LED output
  process(clk)
    begin
      if rising_edge(clk) then
        if write_reg = '1' and rd = "00111" then  -- x7 
          led_reg <= mem_to_reg_data(15 downto 0);
        end if;
      end if;
  end process;

  LED <= led_reg;

end Behavioral;
