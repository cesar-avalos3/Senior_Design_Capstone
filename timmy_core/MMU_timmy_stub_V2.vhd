----------------------------------------------------------------------------------
-- Engineer: Longofono
-- Create Date: 02/10/2018 07:53:02 PM
-- Module Name: MMU_stub - Behavioral
-- Description: Simple stub of MMU to feed instructions and store data 
-- 
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library config;
use work.config.all;

use IEEE.NUMERIC_STD.ALL;

entity MMU_timmy_stub_V2 is
    Port(
        clk: in std_logic;
        rst: in std_logic;
        addr_in: in doubleword;
        data_in: in doubleword;
        satp: in doubleword;
        mode: in std_logic_vector(1 downto 0); -- Machine mode, user mode, hypervisor mode or machine mode
        store: in std_logic;
        load: in std_logic;
        busy: out std_logic;
        ready_instr: in std_logic;
        addr_instr: in doubleword;
        alignment: in std_logic_vector(3 downto 0);
        data_out: out doubleword;
        instr_out: out doubleword;
        error: out std_logic_vector(5 downto 0);
        debug_MEM: out doubleword; -- Dummy register that will be written to
        ddr2_addr : out STD_LOGIC_VECTOR (12 downto 0);
        ddr2_ba : out STD_LOGIC_VECTOR (2 downto 0);
        ddr2_ras_n : out STD_LOGIC;
        ddr2_cas_n : out STD_LOGIC;
        ddr2_we_n : out STD_LOGIC;
        ddr2_ck_p : out std_logic_vector(0 downto 0);
        ddr2_ck_n : out std_logic_vector(0 downto 0);
        ddr2_cke : out std_logic_vector(0 downto 0);
        ddr2_cs_n : out std_logic_vector(0 downto 0);
        ddr2_dm : out STD_LOGIC_VECTOR (1 downto 0);
        ddr2_odt : out std_logic_vector(0 downto 0);
        ddr2_dq : inout STD_LOGIC_VECTOR (15 downto 0);
        ddr2_dqs_p : inout STD_LOGIC_VECTOR (1 downto 0);
        ddr2_dqs_n : inout STD_LOGIC_VECTOR (1 downto 0));
end MMU_timmy_stub_V2;

architecture Behavioral of MMU_timmy_stub_V2 is

component ram_controller_timmy is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
           data_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
           write, read: in STD_LOGIC;
           done: out STD_LOGIC;
           contr_addr_in : in STD_LOGIC_VECTOR(26 DOWNTO 0);
           ddr2_addr : out STD_LOGIC_VECTOR (12 downto 0);
           ddr2_ba : out STD_LOGIC_VECTOR (2 downto 0);
           ddr2_ras_n : out STD_LOGIC;
           ddr2_cas_n : out STD_LOGIC;
           ddr2_we_n : out STD_LOGIC;
           ddr2_ck_p : out std_logic_vector(0 downto 0);
           ddr2_ck_n : out std_logic_vector(0 downto 0);
           ddr2_cke : out std_logic_vector(0 downto 0);
           ddr2_cs_n : out std_logic_vector(0 downto 0);
           ddr2_dm : out STD_LOGIC_VECTOR (1 downto 0);
           ddr2_odt : out std_logic_vector(0 downto 0);
           ddr2_dq : inout STD_LOGIC_VECTOR (15 downto 0);
           ddr2_dqs_p : inout STD_LOGIC_VECTOR (1 downto 0);
           ddr2_dqs_n : inout STD_LOGIC_VECTOR (1 downto 0));
end component;

signal w_en, r_en, m_ready: std_logic := '0';

constant size_mem_instr: integer := 32;
constant size_mem_randm: integer := 32;
constant index_upper_limit: integer := size_mem_instr * 8;

type instsmem is array(0 to (size_mem_instr-1)) of doubleword;
type mem is array(0 to (size_mem_randm - 1)) of doubleword;

signal memory: mem := (others => (others => '0'));
signal instructions: instsmem := (
    zero_word & "00000000000100000000000010010011", --MOV 1 to reg 1
    zero_word & "00000000000100000010000000100011", --SW store 1 to mem
    zero_word & "00000000001000000000000010010011", --MOV 2 to reg 1
    zero_word & "00000000010000000000000010010011", --MOV 4 to reg 1
    zero_word & "00000000100000000000000010010011", --MOV 8 to reg 1
    zero_word & "00000000010000000000000010010011", --MOV 4 to reg 1
    zero_word & "00000000001000000000000010010011", --MOV 2 to reg 1
    zero_word & "00000000000100000010000000100011", --SW store 2 to mem
    zero_word & "00000001000000000000000010010011", --MOV 16 to reg 1
    zero_word & "00000000100000000000000010010011", --MOV 8 to reg 1
    zero_word & "00000010000000000000000010010011", --MOV 32 to reg 1
    zero_word & "00000100000000000000000010010011", --MOV 64 to reg 1
    zero_word & "00000000010000000000000010010011", --MOV 4 to reg 1
    zero_word & "00000000000100000010000000100011", --SW store 4 to mem
    zero_word & "00000010000000000000000010010011", --MOV 32 to reg 1
    zero_word & "00000100000000000000000010010011", --MOV 64 to reg 1
    zero_word & "00000000100000000000000010010011", --MOV 8 to reg 1
    zero_word & "00000000000100000010000000100011", --SW store 8 to mem
    zero_word & "00000010000000000000000010010011", --MOV 32 to reg 1
    zero_word & "00000100000000000000000010010011", --MOV 64 to reg 1
    zero_word & "00000001000000000000000010010011", --MOV 16 to reg 1
    zero_word & "00000000000100000010000000100011", --SW store 16 to mem
    others => (others => '0')
    );
signal PC: integer;
signal index: integer;
signal lastData: doubleword;
constant ones_word: word := (others => '1');

-- Errors: <invalid PC> <misaligned> <protected region> <other> <other2> <other3>
signal error_out: std_logic_vector(5 downto 0);

-- Virtual address
signal vpn_2:   std_logic_vector(25 downto 0);
signal vpn_1:   std_logic_vector(8  downto 0);
signal vpn_0:   std_logic_vector(8  downto 0);
signal p_offset:std_logic_vector(8  downto 0);

-- Page Table Entry 
signal ppn_2: std_logic_vector(25 downto 0);
signal ppn_1: std_logic_vector(8  downto 0);
signal ppn_0: std_logic_vector(8  downto 0);

signal satp_mode: std_logic_vector(3 downto 0);
signal satp_ppn:  std_logic_vector(43 downto 0);


------------------ Physical Address is then ----------------------------
--
-- ppn_2 | ppn_1 | ppn_0 | p_offset
--
-----------------------------------------------------------------------
signal s_debug_MEM: doubleword := (others => '0');

type state is (idle, loading, storing, fetching);
signal curr_state: state;
signal next_state: state;

type mem_state is (idle, low, low_mid, upper_mid, upper, done);
signal mem_curr_state_read : mem_state;
signal mem_next_state_read : mem_state;
signal mem_curr_state_write, mem_next_state_write: mem_state;

signal RAM_data_in: std_logic_vector(15 downto 0);
signal RAM_data_out: std_logic_vector(15 downto 0);
signal RAM_address_in: std_logic_vector(26 downto 0);
signal RAM_done: std_logic;

signal RAM_ctr: integer := 0;
begin

satp_mode <= satp(63 downto 60);
satp_ppn  <= satp(43 downto 0); 

myTimmyMemory: ram_controller_timmy
    port map(
    clk        => clk, 
    rst        => rst, 
    data_in    => RAM_data_in,
    data_out   => RAM_data_out,
    done       => RAM_done,
    write      => w_en, 
    read       => r_en, 
    contr_addr_in  => RAM_address_in, 
    ddr2_addr  => ddr2_addr , 
    ddr2_ba    => ddr2_ba   , 
    ddr2_ras_n => ddr2_ras_n, 
    ddr2_cas_n => ddr2_cas_n, 
    ddr2_we_n  => ddr2_we_n , 
    ddr2_ck_p  => ddr2_ck_p , 
    ddr2_ck_n  => ddr2_ck_n , 
    ddr2_cke   => ddr2_cke  , 
    ddr2_cs_n  => ddr2_cs_n , 
    ddr2_dm    => ddr2_dm   , 
    ddr2_odt   => ddr2_odt  ,
    ddr2_dq    => ddr2_dq   , 
    ddr2_dqs_p => ddr2_dqs_p, 
    ddr2_dqs_n => ddr2_dqs_n 
    );
-- Advance state
process(clk, rst)
begin
    if('1' = rst) then
  --      memory <= (others => (others => '0'));
  --      lastData <= (others => '0');
        curr_state <= idle;
  --      mem_curr_state_read  <= idle;
  --      mem_curr_state_write <= idle;

    elsif(rising_edge(clk)) then
        curr_state <= next_state;
        mem_curr_state_read <= mem_next_state_read;
        mem_curr_state_write <= mem_next_state_write;
    end if;
end process;

process(curr_state)
begin
    error_out <= "000000";
    busy <= '1';    
    next_state <= curr_state;
    PC <= to_integer(unsigned(addr_instr));

    case curr_state is
      when idle => -- Idle, initiate work
        RAM_ctr <= 0;
        -- Allow core to proceed
        busy <= '0';
        if('1' = load) then             -- Handle loads and stores before fetching
            next_state <= loading;
          --  r_en <= '1';
        elsif('1' = store) then
            next_state <= storing;
            w_en <= '1';
        elsif('1' = ready_instr) then
            next_state <= fetching;
            r_en <= '1';
        end if;

      when fetching => -- Handle instruction fetch
          if(m_ready = '0') then
            next_state <= fetching;
          else
            next_state <= idle;
          end if;
      when loading  => -- Handle load
          if(mem_curr_state_read = idle) then
            --mem_next_state_read <= low;
          elsif(mem_curr_state_read = done) then
            next_state <= idle;
            r_en <= '0';
          else
            next_state <= loading;
          end if;
      when others =>  -- Handle store
        if(m_ready = '0') then
          next_state <= storing;
          w_en <= '0';
        else            
          next_state <= idle;
        end if;
    end case;
end process;


-- Process dealing with Memory Addresses and eventually masks
process(clk) begin
    if(mem_curr_state_read = low or mem_curr_state_write = low) then
        RAM_address_in <= addr_in(26 downto 0);
    elsif(mem_curr_state_read = low_mid or mem_curr_state_write = low_mid) then 
        RAM_address_in <= std_logic_vector(unsigned(addr_in(26 downto 0)) + 2);
    elsif(mem_curr_state_read = upper_mid or mem_curr_state_write = upper_mid) then 
        RAM_address_in <=std_logic_vector(unsigned(addr_in(26 downto 0)) + 4);
    elsif(mem_curr_state_read = upper or mem_curr_state_write = upper) then 
        RAM_address_in <=std_logic_vector(unsigned(addr_in(26 downto 0)) + 6);
    end if;
end process;


-- Memory Read State Machine 
process(clk) begin
    case mem_curr_state_read is
    when low =>
        mem_next_state_read <= low;
        if(RAM_done = '1') then
            lastData(15 downto 0) <= RAM_data_out;
            mem_next_state_read <= low_mid;
        end if;
    when low_mid =>
        mem_next_state_read <= low_mid;
        if(RAM_done = '1') then --Valid Data
            lastData(31 downto 16) <= RAM_data_out;
            mem_next_state_read <= upper_mid;
        end if;
    when upper_mid =>
        mem_next_state_read <= upper_mid;
        if(RAM_done = '1') then
            lastData(47 downto 32) <= RAM_data_out;
            mem_next_state_read <= upper;
        end if;
    when upper =>
        mem_next_state_read <= upper;
        if(RAM_done = '1') then
            lastData(63 downto 48) <= RAM_data_out;
            mem_next_state_read <= done;
        end if;
    when done =>
    when others =>
    end case;
end process;


-- Full width writes
-- Memory Write State Machine 
process(clk) begin
    case mem_curr_state_write is
    when low =>
        mem_next_state_write <= low;
        RAM_data_in <= data_in(15 downto 0);
        if(RAM_done = '1') then
            mem_next_state_write <= low_mid;
        end if;
    when low_mid =>
        mem_next_state_write <= low_mid;
        RAM_data_in <= data_in(31 downto 16);
        if(RAM_done = '1') then --Valid Data
            mem_next_state_write <= upper_mid;
        end if;
    when upper_mid =>
        mem_next_state_write <= upper_mid;
        RAM_data_in <= data_in(47 downto 32);
        if(RAM_done = '1') then
            mem_next_state_write <= upper;
        end if;
    when upper =>
        mem_next_state_write <= upper;
        RAM_data_in <= data_in(63 downto 48);
        if(RAM_done = '1') then
            mem_next_state_write <= done;
        end if;
    when done =>
    when others =>
    end case;
end process;


debug_MEM <= lastData;
instr_out <= lastData;
data_out <= lastData;
error <= error_out;

end Behavioral;
