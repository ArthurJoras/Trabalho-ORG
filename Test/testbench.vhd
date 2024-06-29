----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Lucas Karr e Allan Demetrio
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library c0r3x;
use c0r3x.c0r3x_pkg.all;


entity testbench is

end testbench;

architecture Behavioral of testbench is

    component c0rex is
        port (
            signal clk             : in  std_logic :='0';
            signal rst_n           : in  std_logic :='0';
            signal saida_memoria   : in  std_logic_vector (15 downto 0);
            signal entrada_memoria : out std_logic_vector (15 downto 0)         
        ); 
    end component;   
     
    -- control signals
    signal clk_signal               : std_logic :='0';
    signal reset_signal             : std_logic :='0';
    signal saida_memoria_signal     : std_logic_vector (15 downto 0);
    signal entrada_memoria_signal   : std_logic_vector (15 downto 0);
        
    begin
        c0r3x_i : c0r3x
        port map(
            clk                 => clk_s,
            rst_n               => reset_s,   
            saida_memoria       => saida_memoria_s,
            entrada_memoria     => entrada_memoria_s
        );

    -- clock generator - 100MHZ
    clk_s 	<= not clk_s after 5 ns;
    
    -- reset signal
    reset_s		<= '1' after 2 ns,
        '0' after 8 ns;	

end Behavioral;
