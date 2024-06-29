----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Lucas Karr e Allan Demetrio
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library c0r3x;
use c0r3x.c0r3x_pkg.all;

entity c0r3x is
  Port (
      rst_n                  : in  std_logic;
      clk                    : in  std_logic;
      saida_memoria          : in  std_logic_vector (15 downto 0);
      entrada_memoria        : out std_logic_vector (15 downto 0);
      mem_write_enable       : out std_logic;
      mem_read_enable        : out std_logic
   );
end c0r3x;

architecture rtl of c0r3x is

    signal pc_enable_signal              : std_logic;
    signal mem_write_enable_signal       : std_logic;
    signal mem_read_enable_signal        : std_logic;
    signal mdr_enable_signal             : std_logic;
    signal ir_enable_signal              : std_logic;
    signal reg_write_enable_signal       : std_logic;
    signal jump_select_signal            : std_logic;
    signal lw_select_signal              : std_logic;
    signal flag_zero_signal              : std_logic;
    signal decoded_instruction_signal    : decoded_instruction_type;
    signal alu_op_signal                 : std_logic_vector (3  downto 0);
    signal saida_memoria_signal          : std_logic_vector (15 downto 0);
    signal entrada_memoria_signal        : std_logic_vector (15 downto 0);
    signal address_pc_signal             : std_logic_vector (7  downto 0);

    begin

        control_unit_i : control_unit
            port map( 
                clk                 => clk,
                rst_n               => rst_n,
                pc_enable           => pc_enable_signal,
                mem_write_enable    => mem_write_enable_signal,
                mem_read_enable     => mem_read_enable_signal,
                inst_reg_enable     => ir_enable_signal,
                mem_data_reg_enable => mdr_enable_signal,
                reg_write_enable    => reg_write_enable_signal,
                jump_select         => jump_select_signal,
                lw_select           => lw_select_signal,
                flag_zero           => flag_zero_signal,
                flag_equal          => '0',
                decoded_inst        => decoded_instruction_signal,
                alu_op              => alu_op_signal
            );

        data_path_i : data_path
            port map (
                clk                 => clk,
                rst_n               => rst_n,
                pc_enable           => pc_enable_signal,
                mem_write_enable    => mem_write_enable_signal,
                mem_read_enable     => mem_read_enable_signal,
                reg_write_enable    => reg_write_enable_signal,
                inst_reg_enable     => ir_enable_signal,
                mem_data_reg_enable => mdr_enable_signal,
                jump_select         => jump_select_signal,
                lw_select           => lw_select_signal,
                flag_zero           => flag_zero_signal,
                flag_equal          => '0',
                alu_op              => alu_op_signal,
                decoded_inst        => decoded_instruction_signal,
                address_pc          => address_pc_signal,
                mem_out             => saida_memoria,
                mem_in              => entrada_memoria
            );
        
        memory_i : memory
            port map(
                clk                 => clk,
                escrita             => mem_write_enable_signal,
                leitura             => mem_read_enable_signal,
                rst_n               => rst_n,
                entrada_memoria     => entrada_memoria_signal,
                endereco_memoria    => address_pc_signal,
                saida_memoria       => saida_memoria_signal
            );
    
end rtl;
