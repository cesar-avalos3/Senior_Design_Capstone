----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2018 07:31:35 PM
-- Design Name: 
-- Module Name: DUMBCORE_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;

library config;
use work.config.all;

use IEEE.STD_LOGIC_1164.ALL;

entity TIMMYCORE_tb is
--  Port ( );
end TIMMYCORE_tb;

architecture Behavioral of TIMMYCORE_tb is

component TIMMYCORE is
    PORT( CLK, RST: in std_logic;
          debug_MEM, r_data2: out doubleword;
          debug_REGGIE: out regfile_arr
        );
end component;

signal clk: std_logic := '0';
signal rst: std_logic := '0';
signal mem, r_data2: doubleword;
signal rst_once : std_logic := '0';
signal debug_REGGIE: regfile_arr;

begin

    DUMBCORE_inst: TIMMYCORE
    port map(
        clk => clk,
        rst => rst,
        debug_MEM => mem,
        r_data2 => r_data2,
        debug_REGGIE => debug_REGGIE

);

    process begin
        if(rst_once = '0') then
            rst <= '1';
            wait for 125ns;
            rst_once <= '1';
        end if;
        rst <= '0';
        clk <= clk xor '1';
        wait for 10ns;
    end process;

end Behavioral;
