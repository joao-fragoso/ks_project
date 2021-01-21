----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:04:44 06/26/2012 
-- Design Name:    K and S Modeling
-- Module Name:    data_path - rtl 
-- Description:    RTL Code for the K and S datapath
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
--          0.02 - Moving Vivado 2017.3
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use ieee.std_logic_unsigned.all;
use work.k_and_s_pkg.all;

entity data_path is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : in  std_logic;
    pc_enable           : in  std_logic;
    ir_enable           : in  std_logic;
    addr_sel            : in  std_logic;
    c_sel               : in  std_logic;
    operation           : in  std_logic_vector ( 1 downto 0);
    write_reg_enable    : in  std_logic;
    flags_reg_enable    : in  std_logic;
    decoded_instruction : out decoded_instruction_type;
    zero_op             : out std_logic;
    neg_op              : out std_logic;
    unsigned_overflow   : out std_logic;
    signed_overflow     : out std_logic;
    ram_addr            : out std_logic_vector ( 4 downto 0);
    data_out            : out std_logic_vector (15 downto 0);
    data_in             : in  std_logic_vector (15 downto 0)
  );--TESTE
end data_path;

architecture rtl of data_path is

signal bus_a : std_logic_vector (15 downto 0); 
signal bus_b : std_logic_vector (15 downto 0);
signal bus_c : std_logic_vector (15 downto 0);
signal ula_out : std_logic_vector (15 downto 0);
signal a_addr : std_logic_vector (1 downto 0); 
signal b_addr : std_logic_vector (1 downto 0);
signal c_addr : std_logic_vector (1 downto 0);
signal register_0 : std_logic_vector (15 downto 0);
signal register_1 : std_logic_vector (15 downto 0);
signal register_2 : std_logic_vector (15 downto 0);
signal register_3 : std_logic_vector (15 downto 0);
signal zero_op_flag : std_logic;
signal neg_op_flag : std_logic;
signal signed_overflow_flag : std_logic;
signal unsigned_overflow_flag : std_logic;
signal instruction : std_logic_vector (15 downto 0);
signal in_pc : std_logic_vector (4 downto 0);
signal mem_addr : std_logic_vector (4 downto 0);
signal program_counter : std_logic_vector (4 downto 0);

begin

    zero_op_flag <= '1' when ula_out = "0000000000000000" else '0';
    neg_op_flag <= '1' when ula_out(15) = '1';
    
    IR : process (clk)
    begin
        if (ir_enable = '1') then
        instruction <= data_in;
        end if;
    end process IR;
    
    decode : process (instruction)
    begin
        a_addr <= "00";
        b_addr <= "00";
        c_addr <= "00";
        mem_addr <= "00000";
        decoded_instruction <= I_NOP;
        if(instruction(15 downto 8) = "10000001") then -- LOAD
            decoded_instruction <= I_LOAD;
            c_addr <= instruction(6 downto 5);
            mem_addr <= instruction(4 downto 0);
        elsif(instruction(15 downto 8) = "10000010") then
            decoded_instruction <= I_STORE;
            a_addr <= instruction(6 downto 5);
            mem_addr <= instruction(4 downto 0);
         elsif(instruction(15 downto 8) = "10010001") then
            decoded_instruction <= I_MOVE;
            a_addr <= instruction(1 downto 0);
            b_addr <= instruction(1 downto 0);
            c_addr <= instruction(3 downto 2);
         elsif(instruction(15 downto 8) = "10100001") then
            decoded_instruction <= I_ADD;
            a_addr <= instruction(1 downto 0);
            b_addr <= instruction(3 downto 2);
            c_addr <= instruction(5 downto 4);
         elsif(instruction(15 downto 8) = "10100010") then
            decoded_instruction <= I_SUB;
            a_addr <= instruction(1 downto 0);
            b_addr <= instruction(3 downto 2);
            c_addr <= instruction(5 downto 4);
         elsif(instruction(15 downto 8) = "10100011") then
            decoded_instruction <= I_AND;
            a_addr <= instruction(1 downto 0);
            b_addr <= instruction(3 downto 2);
            c_addr <= instruction(5 downto 4);
         elsif(instruction(15 downto 8) = "10100100") then
            decoded_instruction <= I_OR;
            a_addr <= instruction(1 downto 0);
            b_addr <= instruction(3 downto 2);
            c_addr <= instruction(5 downto 4);
         elsif(instruction(15 downto 8) = "00000001") then
            decoded_instruction <= I_BRANCH;
            mem_addr <= instruction(4 downto 0);
         elsif(instruction(15 downto 8) = "00000010") then
            decoded_instruction <= I_BZERO;
            mem_addr <= instruction(4 downto 0);
         elsif(instruction(15 downto 8) = "00000011") then
            decoded_instruction <= I_BNEG;
            mem_addr <= instruction(4 downto 0);                
         elsif(instruction(15 downto 8) = "11111111") then
            decoded_instruction <= I_HALT; 
         else 
            decoded_instruction <= I_NOP;        
         end if;
    end process decode;
    
    flags :    process (clk)
    begin
        zero_op <= '0';
        neg_op <= '0';
        signed_overflow <= '0';
        unsigned_overflow <= '0';
        if (flags_reg_enable = '1') then
            zero_op <= zero_op_flag; 
            neg_op <= neg_op_flag;
            signed_overflow <= signed_overflow_flag;
            unsigned_overflow <= unsigned_overflow_flag;
    end if;
    end process flags;
    
    ula : process(bus_a, bus_b, operation) -- ULA 
        begin
        if(operation = "00") then --SOMA
            ula_out <= bus_a + bus_b;
            if (bus_a(15) = '0' AND bus_b(15) = '0') AND ula_out(15) = '1' then
                signed_overflow_flag <= '1'; 
            elsif (bus_a(15) = '1' AND bus_b(15) = '1') AND ula_out(15) = '0' then
                signed_overflow_flag <= '1';
            elsif (bus_a(15) = '0' AND bus_b(15) = '1') AND (bus_a >= (NOT bus_b) - "1") then
               unsigned_overflow_flag <= '1';
            elsif (bus_a(15) = '1' AND bus_b(15) = '0') AND ((NOT bus_a) - "1" <= bus_b) then
               unsigned_overflow_flag <= '1';
            elsif (bus_a(15)='1' and bus_b(15)='1') then
               unsigned_overflow_flag <= '1'; 
            end if;
        elsif(operation = "01") then -- SUB
            ula_out <= bus_b - bus_a;
            if(bus_a(15) = '0' AND bus_b(15) = '1') AND ula_out(15) = '1' then 
            signed_overflow_flag <= '1';     
            elsif (bus_a(15) = '1' AND bus_b(15) = '0') AND ula_out(15) = '0' then
            signed_overflow_flag <= '1';    
            elsif (bus_a(15) = '0' and bus_b(15) = '0') and (bus_a >= bus_b) then
            unsigned_overflow_flag <= '1';
            elsif (bus_a(15) = '1' and bus_b(15) = '1') and ((not bus_a) - "1" <= (not bus_b)-1) then
            unsigned_overflow_flag <= '1';
            elsif (bus_a(15)='1' and bus_b(15)='0') then
            unsigned_overflow_flag <= '1'; 
            end if;
        elsif(operation = "10") then --AND    
            ula_out <= bus_a AND bus_b;
        else
            ula_out <= bus_a OR bus_b; --OR 
        end if;
    end process ula;
    
    Seletor_Register_Bank : process (c_sel,ula_out,data_in)
        begin
        if (c_sel='0') then
            bus_c <= data_in;
        else
            bus_c <= ula_out;
        end if;
        end process Seletor_Register_Bank;
    
    Register_Bank : process (clk) --Banco de registradores
    begin
       case  a_addr is 
            when "00" => bus_a <= register_0;
            when "01" => bus_a <= register_1;
            when "10" => bus_a <= register_2;
            when others => bus_a <= register_3;
       end case;
       case  b_addr is 
            when "00" => bus_b <= register_0;
            when "01" => bus_b <= register_1;
            when "10" => bus_b <= register_2;
            when others => bus_b <= register_3;
       end case;
    if (write_reg_enable = '1') then
       case  c_addr is 
            when "00" => register_0 <= bus_c;
            when "01" => register_1 <= bus_c;
            when "10" => register_2 <= bus_c;
            when others => register_3 <= bus_c;
       end case;   
    end if;
    data_out <= bus_a;
    end process Register_Bank;
    
    Addr_mux : process (addr_sel,program_counter,mem_addr) --Multiplexador do endereço de memoria
    begin
    if (addr_sel = '0') then
        ram_addr <= mem_addr; 
    else
        ram_addr <= program_counter;
    end if;
    end process Addr_mux;
    
    Branch_mux : process (branch,program_counter,mem_addr) --Multiplexador do endereço de memoria
    begin
    if (branch = '0') then
        in_pc <= program_counter+1; 
    else
        in_pc <= mem_addr;
    end if;
    end process Branch_mux;
    
    Pc : process (clk)
    begin
    if (rst_n = '0') then
        program_counter <= "00000";
    elsif (pc_enable = '1') then
        program_counter <= in_pc;
    end if;
    end process Pc;
    

end rtl;

