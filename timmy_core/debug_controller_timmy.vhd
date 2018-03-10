----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/31/2017 03:31:33 PM
-- Design Name: 
-- Module Name: Serial_Controller_Controller - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library config;
use work.config.all;

entity Serial_Controller_Controller is
    port (clk,RST: in STD_LOGIC;
          HALT: out STD_LOGIC;
          REGGIE: in regfile_arr;
          UART_RXD: in STD_LOGIC;
          UART_TXD 	: out  STD_LOGIC);
end Serial_Controller_Controller;

architecture Behavioral of Serial_Controller_Controller is
   
    component UART_RX_CTRL is
    port  (UART_RX:    in  STD_LOGIC;
           CLK:        in  STD_LOGIC;
           DATA:       out STD_LOGIC_VECTOR (7 downto 0);
           READ_DATA:  out STD_LOGIC;
           RESET_READ: in  STD_LOGIC
    );
    end component;
   
   component UART_TX_CTRL is
    port( SEND : in  STD_LOGIC;
              DATA : in  STD_LOGIC_VECTOR (7 downto 0);
              CLK : in  STD_LOGIC;
              READY : out  STD_LOGIC;
              UART_TX : out  STD_LOGIC);
   end component;
    -- Types
    type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0);
    type UART_STATE_TYPE is (IDLE, RECEIVE, DECODE, REGISTERS, STEP, STEP_HI, STEP_LO, SEND_CHAR, REGFILE, SEND_CHAR_2, SEND_CHAR_3, SEND_CHAR_4, WAIT_CHAR, KEEP_WAITING_CHAR, LD_REGISTERS_STR, RESET_LO, RESET_HI);
    type BOUNDS is array (integer range<>) of integer;
    
    -- Constants
        constant MAX_STR_LEN : integer := 200;
    constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms

    constant byteUpperLimit : BOUNDS := (7, 15, 23, 31, 39, 47, 55, 63);
    constant byteLowerLimit : BOUNDS := (0, 8,  16, 24, 32, 40, 48, 56);
    

    constant WELCOME_STR_LEN : natural := 6;
    constant BTN_STR_LEN : natural := 24;
    
  constant WELCOME_STR : CHAR_ARRAY(0 to 6) := (X"0A",  --\n
                                                                  X"72",  --\r
                                                                  X"4E",  --r
                                                                  X"65",  --e
                                                                  X"67",  --g
                                                                  X"23",  --#
                                                                  X"3a"  --:
                                                                  ); --\r

  constant REG_STR : CHAR_ARRAY(0 to 6) := (
                                            X"72",  --r
                                            X"65",  --\r
                                            X"67",  --r
                                            X"69",  --e
                                            X"73",  --g
                                            X"23",  --#
                                            X"3a"  --:
                                            ); --\r

    -- Signals
    signal uart_curr_state, uart_next_state : UART_STATE_TYPE := idle;
    signal uartRdy, uartSend ,uartTX: std_logic;
    signal uartData: std_logic_vector(7 downto 0);
    signal sendStr : CHAR_ARRAY(0 to (MAX_STR_LEN - 1)) := (
     X"72",
     X"72",
     X"65",
     X"67",
     X"69",
     X"73",
     X"72",
     X"20",
     X"31",
     X"3A",
     X"20",
     X"20",
     X"20",
     others => (others => '0')   
    );
    signal reset_cntr : std_logic_vector (17 downto 0) := (others=>'0');

    signal reggie_counter : integer := 0;
    signal reggie_str_counter : integer := 12;
    signal reggie_counter_counter : integer := 0;
    signal turn : integer := 0;
    signal halt_s : std_logic_vector(2 downto 0);
    signal halt_l : std_logic := '1';

    signal step_mode : std_logic := '0';

    signal strEnd, strIndex: natural := 0;
    signal uart_data_in: STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal data_available, reset_read: STD_LOGIC;
    
    signal rx_str : CHAR_ARRAY(30 DOWNTO 0);
    signal rx_str_ctr : integer := 0;
       
    signal reg_done: std_logic := '0';
    
    signal strConcatCtr: integer := 0;
    
    begin
    uut: UART_TX_CTRL port map(SEND => uartSend,
		                       DATA => uartData,
		                       CLK => CLK,
		                       READY => uartRdy,
		                       UART_TX => UART_TXD );

    inst_UART_RX_CTRL: UART_RX_CTRL
        port map(
          UART_RX => UART_RXD,
          CLK => CLK,
          DATA => uart_data_in,
          READ_DATA => data_available,
          RESET_READ => reset_read
        );
           
    --State Machine transition
    fsm_uart: process(clk, rst) begin
        if(rst = '1') then
            uart_curr_state <= IDLE;
        elsif(rising_edge(clk)) then
            uart_curr_state <= uart_next_state;
        end if;
    end process;
   
    HALT <= halt_l;

    process(clk, rst) begin
        if(rst = '1') then
            strConcatCtr <= 0;
            reggie_str_counter <= 0;
            reset_read <= '1';
            uart_next_state <= IDLE;
            strIndex <= 0;
            halt_l <= '0';
        elsif(rising_edge(clk)) then
            case uart_curr_state is
                when IDLE =>
                    reggie_counter_counter <= 0;
                    reggie_str_counter <= 0;
                    strConcatCtr <= 0;
                    strEnd <= 97;
                    uartSend <= '0';
                    strIndex <= 0;
                    reset_read <= '0';
                    reggie_counter <= 0;
                    uart_next_state <= IDLE;                            -- Default go to IDLE
                    if(data_available = '1' AND uartRdy = '1' ) then    -- If we have data and not outputing anything
                        rx_str(0) <= uart_data_in;                      -- Save the data
                        uart_next_state <= DECODE;
                    end if;
                when DECODE =>
                    if(rx_str(0) = X"72") then
                        uart_next_state <= REGFILE;
                    elsif(rx_str(0) = X"73") then
                        uart_next_state <= STEP;
                    else
                        uart_next_state <= IDLE;
                    end if;
                when REGFILE =>
                    uart_next_state <= REGFILE;
                    if( reggie_counter_counter = 15) then
                        reggie_counter <= reggie_counter + 1;
                    end if;
                    if(reggie_counter >= 7) then
                        uart_next_state <= REGISTERS;
                    else
                        reggie_str_counter <= reggie_str_counter + 1;
                        case reggie_str_counter is
                            when 0  => sendStr(reggie_counter * 13 + reggie_str_counter) <= X"20";
                                       reggie_counter_counter <= 0;
                            when 1  => sendStr(reggie_counter * 13 + reggie_str_counter) <= X"72";
                                       reggie_counter_counter <= 1;                                                               
                            when 2  => sendStr(reggie_counter * 13 + reggie_str_counter) <= "0011" & std_logic_vector(to_unsigned(reggie_counter, 4));
                                       reggie_counter_counter <= 2;
                            when 10  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(7  downto 0);
                                       reggie_counter_counter <= 10;
                            when 9  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(15 downto 8);
                                       reggie_counter_counter <= 9;
                            when 8  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(23 downto 16);
                                       reggie_counter_counter <= 8;
                            when 7  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(31 downto 24);
                                       reggie_counter_counter <= 7;
                            when 6  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(39 downto 32);
                                       reggie_counter_counter <= 6;
                            when 5  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(47 downto 40);
                                       reggie_counter_counter <= 5;
                            when 4  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(55 downto 48);
                                       reggie_counter_counter <= 4;
                            when 3  => sendStr(reggie_counter * 13 + reggie_str_counter) <= reggie(reggie_counter)(63 downto 56);
                                       reggie_counter_counter <= 3;
                            when 11  => sendStr(reggie_counter * 13 + reggie_str_counter) <= X"20";
                                       reggie_counter_counter <= 11;
                            when 12 => sendStr(reggie_counter * 13 + reggie_str_counter)  <= X"0A";
                                       reggie_counter_counter <= 12;
                            when 13 => sendStr(reggie_counter * 13 + reggie_str_counter) <=  X"20";
                                       reggie_counter_counter <= 13;
                            when 14 => sendStr(reggie_counter * 13 + reggie_str_counter) <=  X"20";
                                       reggie_counter_counter <= 14;
                            when 15 => sendStr(reggie_counter * 13 + reggie_str_counter) <=  X"20";
                                       reggie_counter_counter <= 15;
                                       reggie_str_counter <= 0;
                            when others => sendStr(21) <= X"20";
                        end case;
                    end if;
                when STEP =>
                    halt_l <= '0';
                    uart_next_state <= STEP_HI;
                when STEP_HI =>
                    halt_l <= '1';
                    uart_next_state <= STEP_LO;
                when STEP_LO =>
                    halt_l <= '1';
                    uart_next_state <= RESET_LO;
                when REGISTERS =>
                    uart_next_state <= SEND_CHAR;
                when SEND_CHAR =>
                    strIndex <= strIndex + 1;
                    uartSend <= '1';
                    uartData <= sendStr(strIndex);
                    uart_next_state <= WAIT_CHAR;
                when WAIT_CHAR =>
                    uart_next_state <= WAIT_CHAR;
                    if(strEnd <= strIndex) then
                        uart_next_state <= RESET_LO;
                    elsif(uartRdy = '1') then
                        uart_next_state <= SEND_CHAR;
                    end if;
                when RESET_LO =>
                    reset_read <= '1';
                    uart_next_state <= RESET_HI;
                when RESET_HI =>
                    reset_read <= '0';
                    uart_next_state <= IDLE;
                when OTHERS =>
                    uart_next_state <= IDLE;
            end case;
        end if;
    end process;




 --   --RX State machine
 --   rx_state: process(clk,rst) begin
 --       if(rst = '1') then
 --           halt_l <= '0';
 --           reset_read <= '1';
 --           uart_next_state <= IDLE;
 --           strIndex <= 0;
 --       elsif rising_edge(clk) then
 --           case uart_curr_state is
 --               when IDLE =>
 --                   reset_read <= '0';
 --                   uart_next_state <= IDLE;                                 -- By default next state is IDLE
 --                   if(data_available = '1' AND uartRdy = '1') then          -- if we have data
 --                       rx_str(0) <= uart_data_in;                           -- Save data
 --                       uart_next_state <= DECODE;                           -- Decode
 --                   end if;
 --               when RECEIVE =>
 --                   uart_next_state <= DECODE;
 --               when DECODE =>
 --                   uart_next_state <= REGISTERS;
 --                       if(halt_l = '0') then
 --                           HALT <= "111";
 --                           halt_l <= '1';
 --                       else
 --                           HALT <= "000";
 --                           halt_l <= '0';
 --                       end if;
 --                   --elsif(rx_str(0) = X"73") then -- 0x73 = s
 --                  --     uart_next_state <= STEP;
 --                  -- else
 --                   --    uart_next_state <= IDLE;
 --                  -- end if;
 --               when STEP =>
 --                   uart_next_state <= SEND_CHAR;                  
 --               when REGISTERS =>
 --                   uart_next_state <= SEND_CHAR;
 --               when LD_REGISTERS_STR =>
 --                   uart_next_state <= SEND_CHAR;
 --               when SEND_CHAR =>
 --                   strIndex <= strIndex + 1;
 --                   uart_next_state <= KEEP_WAITING_CHAR;
 --               when KEEP_WAITING_CHAR =>
 --                   uart_next_state <= KEEP_WAITING_CHAR;
 --                   if(strIndex => strEnd) then
 --                       uart_next_state <= RESET_LO;
 --                   elsif(uartRdy = '1') then
 --                       uart_next_state <= SEND_CHAR;
 --                   end if;
 --               when RESET_LO =>
 --                   reset_read <= '1';
 --                   uart_next_state <= RESET_HI;
 --               when RESET_HI =>
 --                   reset_read <= '1';
 --                   uart_next_state <= IDLE;
 --               when OTHERS =>
 --                   uart_next_state <= IDLE;
 --           end case;
 --       end if;
 --   end process;

    --Loads SendString and StrEnd signals when LD is reached
    string_load: process(clk) begin
        if(rising_edge(clk)) then
            if (uart_curr_state = REGISTERS) then
          --        sendStr(0) <= X"72";  --\n
          --        sendStr(1) <= X"01";
          --        sendStr(2) <= X"01";
          --        sendStr(3) <= X"01";
          --        sendStr(4) <= X"01";                           
          --        sendStr(5) <= X"01";
          --        sendStr(6) <= reggie(0)(7 downto 0);
          --        sendStr(7) <= reggie(0)(15 downto 8);
      --            strEnd <= 8;
            elsif (uart_curr_state = STEP) then
       --         sendStr(0) <= X"73"; 
       --         sendStr(1) <= X"74";
       --         sendStr(2) <= X"65";
       --         sendStr(3) <= X"70";
       --         sendStr(4) <= X"70";
       --         sendStr(5) <= X"69";
       --         sendStr(6) <= X"6e";
       --         sendStr(7) <= X"67";
       --         strEnd <= 7;
            elsif( uart_curr_state = RESET_LO) then
       --         sendStr <= (others => (others => '1'));
       --         strEnd <= 10;
            end if;
         end if;
      end process;

 --   --STRindex control
 --   char_count: process(clk) begin
 --       if(rising_edge(clk)) then
 --           if(uart_curr_state = SEND_CHAR) then
 --       --        strIndex <= strIndex + 1; --Plus 2 for som reason
 --           elsif(uart_curr_state = IDLE) then
 --       --        strIndex <= 0;
 --           else
 --       --        strIndex <= strIndex;
 --           end if;
 --       end if;
 --   end process;
    
 --   --Control UART_TX_CTRL
 --   char_load: process(clk) begin
 --      if(rising_edge(clk)) then
 --       if(uart_curr_state = SEND_CHAR) then
 --           uartSend <= '1';
 --           uartData <= sendStr(strIndex);
 --       else
 --           uartSend <= '0';
 --       end if;
 --     end if;
 --  end process;

end Behavioral;
