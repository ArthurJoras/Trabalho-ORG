----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Lucas Karr e Allan Demetrio
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

package c0r3x_pkg is
                                                                                                                                                            
	type decoded_instruction_type is (I_ADD, I_SUB, I_AND, I_NOT, I_JMP, I_BEQ, I_BNE, I_LW, I_SW);
  
	component data_path
		Port (
			clk                     : in  std_logic;
			rst_n                   : in  std_logic;
			pc_enable               : in  std_logic;
			mem_write_enable        : in  std_logic;
			mem_read_enable         : in  std_logic;
			reg_write_enable        : in  std_logic;
			inst_reg_enable         : in  std_logic;
			mem_data_reg_enable     : in  std_logic;
			jump_select             : in  std_logic;
			lw_select               : in  std_logic;
			
			flag_zero           : out std_logic;
			flag_equal		  	: out std_logic;
			
			alu_op              : in  std_logic_vector (3 downto 0);
			decoded_inst        : out decoded_instruction_type;
			address_pc          : out std_logic_vector (7 downto 0);

			mem_out             : in  std_logic_vector (15 downto 0);
			mem_in              : out std_logic_vector (15 downto 0)
		);
	end component;

	component control_unit
		Port ( 
			clk                 : in  std_logic;
			rst_n               : in  std_logic;
			pc_enable           : out std_logic;
			mem_write_enable    : out std_logic;
			mem_read_enable     : out std_logic;       
			inst_reg_enable		: out std_logic;
			mem_data_reg_enable	: out std_logic;
			reg_write_enable	: out std_logic;
			jump_select			: out std_logic;
			lw_select			: out std_logic;
			flag_zero           : in  std_logic;
			flag_equal			: in  std_logic;
			decoded_inst        : in  decoded_instruction_type;
			alu_op              : out std_logic_vector(3 downto 0)
		);
	end component;
  
	component memory is
		port(        
			clk                 : in  std_logic;
			escrita             : in  std_logic;
			leitura             : in  std_logic;
			rst_n               : in  std_logic;        
			entrada_memoria     : in  std_logic_vector(15 downto 0);
			endereco_memoria    : in  std_logic_vector(7  downto 0);
			saida_memoria       : out std_logic_vector(15 downto 0)
          );      
	end component;

	component c0r3x
		port (
			rst_n                  : in  std_logic;
			clk                    : in  std_logic;
			adress_pc    		   : in  std_logic_vector (7  downto 0);
			saida_memoria          : in  std_logic_vector (15 downto 0);
			entrada_memoria        : out std_logic_vector (15 downto 0); 
			mem_write_en           : out std_logic;
			mem_read_en            : out std_logic
		);
	end component;
  
	component testbench is
		port (
			signal clk 				: in  std_logic := '0';
			signal reset 			: in  std_logic;
			signal saida_memoria 	: in  std_logic_vector (15 downto 0);
			signal entrada_memoria 	: out std_logic_vector (15 downto 0)
		); 
	end component;   

end c0r3x_pkg;

package body c0r3x_pkg is
end c0r3x_pkg;