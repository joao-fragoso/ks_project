----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:08:01 06/26/2012 
-- Design Name:    K and S modeling
-- Module Name:    control_unit - rtl 
-- Description:    RTL Code for K and S control unit
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
--          0.02 - moving to Vivado 2017.3
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.k_and_s_pkg.all;

entity control_unit is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : out std_logic;
    pc_enable           : out std_logic;
    ir_enable           : out std_logic;
    write_reg_enable    : out std_logic;
    addr_sel            : out std_logic;
    c_sel               : out std_logic;
    operation           : out std_logic_vector (1 downto 0);
    flags_reg_enable    : out std_logic;
    decoded_instruction : in  decoded_instruction_type;
    zero_op             : in  std_logic;
    neg_op              : in  std_logic;
    unsigned_overflow   : in  std_logic;
    signed_overflow     : in  std_logic;
    ram_write_enable    : out std_logic;
    halt                : out std_logic
    );
end control_unit;

--22
architecture rtl of control_unit is

    type state_type is (FETCH, DECODE, NEXT1, NEXT2, ULA1, ULA2, LOAD1, LOAD2);
    signal state : state_type;
    
begin

process(clk, rst_n)
    begin
    if rst_n = '1' then
        state <= FETCH;
        
    elsif(rising_edge(clk)) then
        case state is
            when FETCH=>
            ir_enable <= '1';
            state <= DECODE;
            
            when DECODE=>
                if decoded_instruction = I_LOAD then
                    state <= LOAD1;
                 elsif decoded_instruction = I_STORE then
                 
                 else
            end if;
            when LOAD1=>
                addr_sel <= '0';
                state <= LOAD2;
            when LOAD2=>
            c_sel <= '1'; 
            write_reg_enable <= '1';
            state <= NEXT1;
            when ULA1 =>
            if decoded_instruction = I_ADD then
                    operation <= "00";
                    state <= LOAD1;
            elsif decoded_instruction = I_SUB then
                    operation <= "01";
            end if;
           end case;
            
     end if;
end process;


end rtl;

