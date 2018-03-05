library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram_controller_timmy is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR(15 DOWNTO 0);
           data_out : out STD_LOGIC_VECTOR(15 DOWNTO 0);
           done: out STD_LOGIC;
           write, read: in STD_LOGIC;
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
end ram_controller_timmy;

architecture Behavioral of ram_controller_timmy is

component clk_wiz_0
    port(
    clk_in1 : in std_logic;
    clk_100MHz_o: out std_logic;
    clk_200MHz_o: out std_logic;
    locked_o: out std_logic);
end component;

component ram2ddrxadc
    port(
     clk_200MHz_i         : in    std_logic; -- 200 MHz system clock
     rst_i                : in    std_logic; -- active high system reset
     device_temp_i        : in    std_logic_vector(11 downto 0);
     
     -- RAM interface
     -- The RAM is accessing 2 bytes per access
     ram_a                : in    std_logic_vector(26 downto 0); -- input address
     ram_dq_i             : in    std_logic_vector(15 downto 0); -- input data
     ram_dq_o             : out   std_logic_vector(15 downto 0); -- output data
     ram_cen              : in    std_logic;                     -- chip enable
     ram_oen              : in    std_logic;                     -- output enable
     ram_wen              : in    std_logic;                     -- write enable
     ram_ub               : in    std_logic;                     -- upper byte
     ram_lb               : in    std_logic;                     -- lower byte
     
     -- DDR2 interface
     ddr2_addr            : out   std_logic_vector(12 downto 0);
     ddr2_ba              : out   std_logic_vector(2 downto 0);
     ddr2_ras_n           : out   std_logic;
     ddr2_cas_n           : out   std_logic;
     ddr2_we_n            : out   std_logic;
     ddr2_ck_p            : out   std_logic_vector(0 downto 0);
     ddr2_ck_n            : out   std_logic_vector(0 downto 0);
     ddr2_cke             : out   std_logic_vector(0 downto 0);
     ddr2_cs_n            : out   std_logic_vector(0 downto 0);
     ddr2_dm              : out   std_logic_vector(1 downto 0);
     ddr2_odt             : out   std_logic_vector(0 downto 0);
     ddr2_dq              : inout std_logic_vector(15 downto 0);
     ddr2_dqs_p           : inout std_logic_vector(1 downto 0);
     ddr2_dqs_n           : inout std_logic_vector(1 downto 0)
    );
    end component;

signal ram_cen, ram_oen, ram_wen, ram_ub, ram_lb: std_logic;
signal clk_100, clk_200, locked : std_logic;
signal ram_dq_o, ram_dq_i: std_logic_vector (15 downto 0);
type memory_states IS (idle, prepare, read_access_low, write_access_low, intermitent,access_mid_low, access_mid_high,access_high);
-- Where current state and next_state are pretty self-forward, last state will check
signal current_state, next_state, last_state: memory_states := idle;

signal temp_data_write, temp_data_read: std_logic_vector(63 downto 0);
signal ram_a: std_logic_vector(26 downto 0);

signal read_out: std_logic_vector(15 downto 0) := (others => '0');

signal four_times : integer range 0 to 150 := 0;
signal s_read : std_logic := '0'; 

signal writeOnce, readOnce : std_logic := '0';
begin

clk_wizard: clk_wiz_0 
port map(
    clk_in1 =>clk,
    clk_100MHz_o => clk_100,
    clk_200MHz_o => clk_200,
    locked_o => locked
);

ram2ddr: ram2ddrxadc 
port map(
        clk_200MHz_i=>clk_200,
        rst_i=>rst,                
        device_temp_i=>"000000000000",        
        ram_a=>ram_a,     
        ram_dq_i=>ram_dq_o,             
        ram_dq_o=>ram_dq_i,             
        ram_cen=>ram_cen,              
        ram_oen=>ram_oen,               
        ram_wen=>ram_wen,              
        ram_ub=>ram_ub,               
        ram_lb=>ram_lb,               
       
        ddr2_addr=>ddr2_addr,            
        ddr2_ba=>ddr2_ba,              
        ddr2_ras_n=>ddr2_ras_n,           
        ddr2_cas_n=>ddr2_cas_n,           
        ddr2_we_n=>ddr2_we_n,            
        ddr2_ck_p=>ddr2_ck_p,            
        ddr2_ck_n=>ddr2_ck_n,            
        ddr2_cke=>ddr2_cke,             
        ddr2_cs_n=>ddr2_cs_n,            
        ddr2_dm=>ddr2_dm,              
        ddr2_odt=>ddr2_odt,             
        ddr2_dq=>ddr2_dq,              
        ddr2_dqs_p=>ddr2_dqs_p,           
        ddr2_dqs_n=>ddr2_dqs_n        
);

process(clk_100,rst) begin
    if(rst = '1') then
        current_state <= idle;
    elsif(rising_edge(clk_100)) then
        current_state <= next_state;
    end if;
end process;

process(current_state, rst) begin
    
    if(rst = '1') then
        read_out <= (others => '0');
        readOnce <= '0';
        writeOnce <= '0';
    end if;
    
    next_state <= idle;
    
    case current_state is
    when idle =>
        ram_cen <= '1';
        ram_oen <= '1';
        ram_wen <= '1';
        if(read = '1' AND readOnce = '0') then
            s_read <= '1';
            next_state <= prepare; 
        elsif(write = '1' AND writeOnce = '0') then 
            s_read <= '0';
            next_state <= prepare;
        end if;
    when prepare =>
        four_times <= 0;
        if(s_read = '1') then --read
            readOnce <= '1';
            ram_oen <= '0';
            ram_cen <= '0';
            ram_lb <= '0';
            ram_ub <= '0';
            ram_wen <= '1';
            next_state <= read_access_low;
        else --write
            writeOnce <= '1';
            ram_oen <= '1';
            ram_cen <= '0';
            ram_lb <= '0';
            ram_ub <= '0';
            ram_wen <= '0';
            next_state <= write_access_low;
        end if;
    when read_access_low =>
        ram_lb <= '0';
        ram_ub <= '0';
        next_state <= read_access_low;
        four_times <= four_times + 1;
        read_out <= (2 => '1', others => '0');
        if(four_times > 100) then
           read_out <= ram_dq_i;
           next_state <= intermitent;
           --read_out <= (3 => '1', others => '0');
        end if;
    when write_access_low =>
        ram_wen <= '0';
        ram_oen <= '1';
        ram_cen <= '0';
        ram_lb <= '0';
        ram_ub <= '0';
        next_state <= write_access_low;
        four_times <= four_times + 1;
        if(four_times > 100) then
            next_state <= idle;
            read_out <= (9 => '1', others => '0');
        end if;
    when intermitent =>
        read_out <= ram_dq_i;
        next_state <= idle;
    when others =>
        next_state <= idle;
    end case;
end process;

ram_dq_o <= data_in;
ram_a <= contr_addr_in;
data_out <= read_out;
done <= '1' when current_state = intermitent else '0';
end Behavioral;
