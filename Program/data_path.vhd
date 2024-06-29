----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Lucas Karr e Allan Demetrio
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library c0r3x;
use c0r3x.c0r3x_pkg.all;

entity data_path is
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
    
    flag_zero               : out std_logic;
    flag_equal              : out std_logic;
    
    alu_op                  : in  std_logic_vector (3 downto 0);
    decoded_inst            : out decoded_instruction_type;
    address_pc              : out std_logic_vector (7 downto 0);

    mem_out                 : in  std_logic_vector (15 downto 0);
    mem_in                  : out std_logic_vector (15 downto 0);
  );
end data_path;

architecture rtl of data_path is


    signal data                 : std_logic_vector (15 downto 0);
    signal alu_or_mem_data      : std_logic_vector (15 downto 0);
    signal instruction          : std_logic_vector (15 downto 0); 
    signal mem_addr             : std_logic_vector (7 downto 0); 
    signal program_counter      : std_logic_vector (7 downto 0);
    signal mem_data_reg_to_reg  : std_logic_vector (15 downto 0);

    
    -- registers

     signal regzero             : std_logic_vector (15 downto 0):= "0000000000000000";
     signal reg1                : std_logic_vector (15 downto 0);
     signal reg2                : std_logic_vector (15 downto 0);
     signal reg3                : std_logic_vector (15 downto 0);
     signal reg4                : std_logic_vector (15 downto 0);
     signal reg5                : std_logic_vector (15 downto 0);
     signal reg6                : std_logic_vector (15 downto 0);
     signal reg7                : std_logic_vector (15 downto 0);
     
     signal instruction_reg     : std_logic_vector (15 downto 0); 
     signal mem_data_reg        : std_logic_vector (15 downto 0);
     signal reg_a_alu           : std_logic_vector (15 downto 0);
     signal reg_b_alu           : std_logic_vector (15 downto 0);
     signal reg_alu_out         : std_logic_vector (15 downto 0);
     
         
    -- target register
      
    signal reg_dest     : std_logic_vector(2 downto 0);
    
    -- Reg A  
    signal reg_op_a     : std_logic_vector(2 downto 0);
    
    -- Reg B  
    signal reg_op_b     : std_logic_vector(2 downto 0);
      
   -- ALU signals
    signal a_operand    : std_logic_vector (15 downto 0);      
    signal b_operand    : std_logic_vector (15 downto 0);   
    signal alu_out      : std_logic_vector (15 downto 0);
    
    -- FLAG
    signal zero         : std_logic;
    signal equal        : std_logic;
    
      
    begin
    
    
    alu_or_mem_data <= mem_data_reg_to_reg when (lw_select = '1') else reg_alu_out;
    a_operand <= reg_a_alu;
    b_operand <= reg_b_alu;
    reg_alu_out <= alu_out;
    instruction <= instruction_reg;
    mem_data_reg_to_reg <= mem_data_reg;
    flag_equal <= equal;
    
    ----- DECODIFICADOR DE INSTRUÇÕES -----
    process (instruction)
    begin
        case (instruction(15 downto 12)) is
            when "0000" =>
                -- ADD
                decoded_inst <= I_ADD;
                reg_dest <= instruction(11 downto 9);
                reg_op_a <= instruction(8 downto 6);
                reg_op_b <= instruction(5 downto 3);
            when "0001" =>
                -- SUB
                decoded_inst <= I_SUB;
                reg_dest <= instruction(11 downto 9);
                reg_op_a <= instruction(8 downto 6);
                reg_op_b <= instruction(5 downto 3);
            when "0010" =>
                -- AND
                decoded_inst <= I_AND;
                reg_dest <= instruction(11 downto 9);
                reg_op_a <= instruction(8 downto 6);
                reg_op_b <= instruction(5 downto 3);
            when "0011" =>
                -- NOT
                decoded_inst <= I_NOT;
                reg_dest <= instruction(11 downto 9);
                reg_op_a <= instruction(8 downto 6);
            when "0100" =>
                -- JUMP
                decoded_inst <= I_JMP;
            when "0101" =>
                -- BEQ
                decoded_inst <= I_BEQ;
                mem_addr <= instruction(11 downto 6);
                reg_op_a <= instruction(5 downto 3);
                reg_op_b <= instruction(2 downto 0);
            when "0110" =>
                -- BNEQ
                decoded_inst <= I_BNE;
                mem_addr <= instruction(11 downto 6);
                reg_op_a <= instruction(5 downto 3);
                reg_op_b <= instruction(2 downto 0);
            when "1000" =>
                -- LOAD
                decoded_inst <= I_LW;
                mem_addr <= instruction(11 downto 4);
                reg_op_a <= instruction(3 downto 1);
            when "1001" =>
                -- STORE
                decoded_inst <= I_SW;
                mem_addr <= instruction(11 downto 4);
                reg_op_a <= instruction(3 downto 1);
            when others =>
                -- NOP
                decoded_inst <= I_ADD;
                reg_dest <= "001";
                reg_op_a <= "000"
                reg_op_b <= "001"
        end case;
    end process;
    
    ---- ALU ----
    process(a_operand,b_operand,alu_op)
    begin
        if(alu_op = "0000") then
            alu_out <= a_operand + b_operand; -- ADD
        elsif(alu_op = "0001") then
            alu_out <= a_operand - b_operand; -- SUB
        elsif(alu_op = "0010") then
            alu_out <= a_operand and b_operand; -- AND
        elsif(alu_op = "0011") then
            alu_out <= not a_operand; -- NOT
        elsif(alu_op = "0101") then
            if(a_operand = b_operand) then -- BEQ
                equal <= '1';
            else
                equal <= '0';
            end if;
        elsif(alu_op = "0110") then
            if(a_operand = b_operand) then -- BNE
                equal <= '0';
            else
                equal <= '1';
            end if;
        end if;
    end process;

    process(clk)
    begin
        if (clk'event and clk = '1') then
        
        ---- MEMORIA PARA IR ----
            if(inst_reg_enable = '1' and mem_read_enable = '1') then
                instruction_reg <= mem_out;
            end if;
        
        ---- MEMORIA PARA MDR ----
            if(mem_data_reg_enable = '1' and mem_read_enable = '1') then
                mem_data_reg <= mem_out;
            end if;
            
        ---- CONTROLE PC ----
            if (rst_n='0') then
                program_counter <= "00000000";
            elsif (pc_enable = '1') then
                if (jump_select = '0') then
                    program_counter <= program_counter + 1;
                elsif (jump_select = '1') then
                    program_counter <= mem_addr;
                end if;
            end if;
            
        ---- REG A E REG B ----
            if (reg_op_a = "000") then
                reg_a_alu <= regzero;
            elsif (reg_op_a = "001") then
                reg_a_alu <= reg1;
            elsif (reg_op_a = "010") then
                reg_a_alu <= reg2;
            elsif (reg_op_a = "011") then
                reg_a_alu <= reg3;
            elsif (reg_op_a = "100") then
                reg_a_alu <= reg4;
            elsif (reg_op_a = "101") then
                reg_a_alu <= reg5;
            elsif (reg_op_a = "110") then
                reg_a_alu <= reg6;
            elsif (reg_op_a = "111") then
                reg_a_alu <= reg7;
            end if;
            
            if (reg_op_b = "000") then
                reg_b_alu <= regzero;
            elsif (reg_op_b = "001") then
                reg_b_alu <= reg1;
            elsif (reg_op_b = "010") then
                reg_b_alu <= reg2;
            elsif (reg_op_b = "011") then
                reg_b_alu <= reg3;
            elsif (reg_op_b = "100") then
                reg_b_alu <= reg4;
            elsif (reg_op_b = "101") then
                reg_b_alu <= reg5;
            elsif (reg_op_b = "110") then
                reg_b_alu <= reg6;
            elsif (reg_op_b = "111") then
                reg_a_alu <= reg7;
            end if;
            
        ---- BANCO DE REGISTRADORES ----
            if (reg_write_enable = '1' and reg_dest = "001") then
                reg1 <= alu_or_mem_data;
            elsif (reg_write_enable = '1' and reg_dest = "010") then           
                reg2 <= alu_or_mem_data;
            elsif (reg_write_enable = '1' and reg_dest = "011") then           
                reg3 <= alu_or_mem_data;
            elsif (reg_write_enable = '1' and reg_dest = "100") then
                reg4 <= alu_or_mem_data;
            elsif (reg_write_enable = '1' and reg_dest = "101") then
                reg5 <= alu_or_mem_data;
            elsif (reg_write_enable = '1' and reg_dest = "110") then
                reg6 <= alu_or_mem_data;
            elsif (reg_write_enable = '1' and reg_dest = "111") then
                reg7 <= alu_or_mem_data;
            end if; 
            
        ---- PC PARA ENDEREÇO ----
            if((instruction(15 downto 13)= "0100")) then
               address_pc <= mem_addr;
            elsif (instruction(15 downto 13)= "0101") or (instruction(15 downto 13)= "0110") then
               address_pc <= mem_addr;
            else
               address_pc <= program_counter;
            end if;
            
        end if;
    end process;
            

end rtl;
