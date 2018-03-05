library IEEE;
library config;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config.all;

entity memory_timmy_parallel is
  port(clk, rst, w_en, r_en : in std_logic;
       r_addr_in, w_addr_in: in doubleword;
       data_in: in doubleword;
       ready: out std_logic;
       data_out: out doubleword
      );
end memory_timmy_parallel;

architecture Behavioral of memory_timmy_parallel is

constant memory_size : integer := 50;                --50 doublewords or 8 bytes 
constant memory_blocks : integer := memory_size * 8; --Each element of the memory is 1 byte

type timmy_ram is array(memory_blocks downto 0) of std_logic_vector(7 downto 0); --Byte words
signal timmy_ram_inst : timmy_ram := (others => (others => '0')); 
signal timmy_rom_inst : timmy_ram := ((0 + 0) => x"17", (0 + 1) => x"01", (0 + 2) => x"00", (0 + 3) => x"00", (0 + 4) => x"13", (0 + 5) => x"01", (0 + 6) => x"01", (0 + 7) => x"0b", (0 + 8) => x"6f", (0 + 9) => x"00", (0 + 10) => x"40", (0 + 11) => x"00", (0 + 12) => x"13", (0 + 13) => x"01", (0 + 14) => x"01", (0 + 15) => x"ff", (0 + 16) => x"23", (0 + 17) => x"34", (0 + 18) => x"81", (0 + 19) => x"00", (0 + 20) => x"13", (0 + 21) => x"04", (0 + 22) => x"01", (0 + 23) => x"01", (0 + 24) => x"93", (0 + 25) => x"07", (0 + 26) => x"90", (0 + 27) => x"00", (0 + 28) => x"93", (0 + 29) => x"97", (0 + 30) => x"c7", (0 + 31) => x"01", (0 + 32) => x"13", (0 + 33) => x"07", (0 + 34) => x"f0", (0 + 35) => x"ff", (0 + 36) => x"23", (0 + 37) => x"90", (0 + 38) => x"e7", (0 + 39) => x"00", (0 + 40) => x"6f", (0 + 41) => x"00", (0 + 42) => x"00", (0 + 43) => x"00", (0 + 44) => x"00", others => (others => '1')); 

type memory_states is (idle, b0,b1,b2,b3,b4,b5,b6,b7, done);

signal current_read_1_state, next_read_1_state, current_write_1_state, next_write_1_state;

signal current_state, next_state : memory_states := idle;
signal memory_out : doubleword;
 --Once you initiate read or write with an address, you're stuck with that address til the process finishes
signal r_address_in_temp, w_address_in_temp: doubleword; 

begin

process(clk) begin
  current_state <= next_state;
end process;

process(current_state) begin
  
  case current_state is
    when idle =>
      if(r_en = '1') then
        r_address_in_temp <= r_addr_in;
        next_state <= b0;
      end if;
      if(w_en = '1') then
        w_address_in_temp <= w_addr_in;
        next_state <= b0;
      end if;

    when b0 => --First byte 7654321[0]
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp))) <= data_in(7 downto 0);
      end if;
      if(r_en = '1') then
      memory_out(7 downto 0) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)));
      end if;
      next_state <= b1;
      
    when b1 => --Second byte 765432[1]0
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp)) + 1) <= data_in(15 downto 8);
      end if;
      if(r_en = '1') then
      memory_out(15 downto 8) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)) + 1);
      end if;
      next_state <= b2;
      
    when b2 => --Second byte 76543[2]10
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp)) + 2) <= data_in(23 downto 16);  
      end if;
      if(r_en = '1') then
      memory_out(23 downto 16) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)) + 2);
      end if;
      next_state <= b3;

    when b3 => --Second byte 7654[3]210
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp)) + 3) <= data_in(31 downto 24);  
      end if;
      if(r_en = '1') then
      memory_out(31 downto 24) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)) + 3);
      end if;
      next_state <= b4;
      
    when b4 => --Second byte 765[4]3210
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp)) + 4) <= data_in(39 downto 32);
      end if; 
      if(r_en = '1') then
      memory_out(39 downto 32) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)) + 4);
      end if;
      next_state <= b5;

    when b5 => --Second byte 76[5]43210
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp)) + 5) <= data_in(47 downto 40);  
      end if;
      if(r_en = '1') then
      memory_out(47 downto 40) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)) + 5);
      end if;
      next_state <= b6;

    when b6 => --Second byte 7[6]543210
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp)) + 6) <= data_in(55 downto 48);  
      end if;
      if(r_en = '1') then
      memory_out(55 downto 48) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)) + 6);
      end if;
      next_state <= b7;

    when b7 => --Last byte [7]6543210
      if(w_en = '1') then
      timmy_ram_inst(to_integer(unsigned(w_address_in_temp)) + 7) <= data_in(63 downto 56);  
      end if;
      if(r_en = '1') then
      memory_out(63 downto 56) <= timmy_rom_inst(to_integer(unsigned(r_address_in_temp)) + 7);
      end if;
      next_state <= done;
    
    when done =>
        next_state <= idle;
    end case;
end process;
ready <= '1' when (current_state = done) or (current_state = idle) else '0';
data_out <= memory_out;
end architecture;