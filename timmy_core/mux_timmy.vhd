----------------------------------------------------------------------------------
-- Engineer: Longofono
-- Create Date: 02/10/2018 06:14:36 PM
-- Module Name: mux - Behavioral
-- Description: Simple asynchronous 2 to 1 mux 
-- 
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library config;
use work.config.all;

entity mux_timmy is
    Port(
        sel:        in std_logic;   -- Select from zero, one ports
        zero_port:  in doubleword;  -- Data in, zero select port
        one_port:   in doubleword;  -- Data in, one select port
        out_port:   out doubleword  -- Output data
    );
end mux_timmy;

architecture Behavioral of mux_timmy is
begin

out_port <= one_port when '1' = sel else zero_port;

end Behavioral;
