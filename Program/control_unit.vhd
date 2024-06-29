----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Lucas Karr e Allan Demetrio
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library c0r3x;
use c0r3x.c0r3x_pkg.all;

entity control_unit is
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
end control_unit;


architecture rtl of control_unit is
        
        type state_type is(
        FETCH,
        DECODE,
        ALU,
        LOAD,
        PROX,
        BEQ,
        BNE
        );
        signal current : state_type;    
        signal nextstate : state_type;
        
begin

    process (clk)
        begin
            if (clk'event and clk='1') then
                if (rst_n='0') then
                    current <= FETCH;
                else
                    current <= nextstate;
                end if;
            end if;
    end process;
    
    process(clk,current)
        begin
            --nextstate <= current;
            case (current) is
            
                when FETCH =>
                    pc_enable <= '0';
                    mem_read_enable <= '1';
                    mem_write_enable <= '0';
                    inst_reg_enable <= '1';
                    mem_data_reg_enable <= '0';
                    reg_write_enable <= '0';
                    jump_select <= '0';
                    lw_select <= '0';
                    nextstate <= DECODE;
                
                when DECODE =>
                    mem_read_enable <= '0';
                    inst_reg_enable <= '0';
                    case decoded_inst is
                        when I_ADD =>
                            alu_op <= "0000";
                            nextstate <= ALU;
                        when I_SUB =>
                            alu_op <= "0001";
                            nextstate <= ALU;
                        when I_AND =>
                            alu_op <= "0010";
                            nextstate <= ALU;
                        when I_NOT =>
                            alu_op <= "0011";
                            nextstate <= ALU;
                        when I_JMP =>
                            jump_select <= '1';
                            pc_enable <= '1';
                            nextstate <= FETCH;
                        when I_BEQ =>
                            alu_op <= "0101";
                            nextstate <= BEQ;
                        when I_BNE =>
                            alu_op <= "0110";
                            nextstate <= BNE;
                        when I_LW =>
                            mem_read_enable <= '1';
                            mem_data_reg_enable <= '1';
                            nextstate <= LOAD;
                        when I_SW =>
                            mem_write_enable <= '1';
                            nextstate <= PROX;
                        when others =>
                            nextstate <= PROX;
                            
                    end case;
                
                when ALU =>
                    reg_write_enable <= '1';
                    nextstate <= PROX;
                
                when LOAD =>
                    mem_read_enable <= '0';
                    mem_data_reg_enable <= '0';
                    lw_select <= '1';
                    reg_write_enable <= '1';
                    nextstate <= PROX;
                
                when BEQ =>
                    if (flag_equal = '1') then
                        jump_select <= '1';
                        pc_enable <= '1';
                        nextstate <= FETCH;
                    else
                        nextstate <= PROX;
                    end if;
                
                when BNE =>
                    if (flag_equal = '0') then
                        jump_select <= '1';
                        pc_enable <= '1';
                        nextstate <= FETCH;
                    else
                        nextstate <= PROX;
                    end if;
               
                when others => -- PROX
                    mem_write_enable <= '0';
                    reg_write_enable <= '0';
                    pc_enable <= '1';
                    nextstate <= FETCH;
            
            end case;
    end process;                                                        
end rtl;
