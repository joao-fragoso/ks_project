----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:09:17 06/26/2012 
-- Design Name:    K and S Modeling
-- Module Name:    k_and_s - rtl 
-- Description:    Top Module of the K and S processor. Instantiate datapath
-- and control unit modules
--
-- Dependencies: datapath.vhd, control_unit.vhd
--
-- Revision: 
-- Revision 0.01 - File Created
--          0.02 - Moving to Vivado 2017.3
-- Additional Comments: 
-- test mauzin
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.k_and_s_pkg.all;

entity k_and_s is
  port (
    rst_n        : in  std_logic;
    clk          : in  std_logic;
    halt         : out std_logic;
    addr         : out std_logic_vector (4 downto 0);
    data_in      : in  std_logic_vector (15 downto 0);
    data_out     : out std_logic_vector (15 downto 0);
    write_enable : out std_logic
    );
end k_and_s;

architecture rtl of k_and_s is
  signal branch_s              : std_logic;
  signal pc_enable_s           : std_logic;
  signal ir_enable_s           : std_logic;
  signal addr_sel_s            : std_logic;
  signal c_sel_s               : std_logic;
  signal flags_reg_enable_s    : std_logic;
  signal decoded_instruction_s : decoded_instruction_type;
  signal write_reg_enable_s    : std_logic;
  signal operation_s           : std_logic_vector(1 downto 0);
  signal zero_op_s             : std_logic;
  signal neg_op_s              : std_logic;
  signal unsigned_overflow_s   : std_logic;
  signal signed_overflow_s     : std_logic;
begin

  control_unit_i: control_unit
    port map (
      rst_n               => rst_n,
      clk                 => clk,
      branch              => branch_s,
      pc_enable           => pc_enable_s,
      ir_enable           => ir_enable_s,
      addr_sel            => addr_sel_s,
      c_sel               => c_sel_s,
      operation           => operation_s,
      write_reg_enable    => write_reg_enable_s,
      flags_reg_enable    => flags_reg_enable_s,
      decoded_instruction => decoded_instruction_s,
      zero_op             => zero_op_s,
      neg_op              => neg_op_s,
      unsigned_overflow   => unsigned_overflow_s,
      signed_overflow     => signed_overflow_s,
      halt                => halt,
      ram_write_enable    => write_enable
    );

  datapath_i: data_path
    port map (
      rst_n               => rst_n,
      clk                 => clk,
      branch              => branch_s,
      pc_enable           => pc_enable_s,
      ir_enable           => ir_enable_s,
      addr_sel            => addr_sel_s,
      c_sel               => c_sel_s,
      operation           => operation_s,
      write_reg_enable    => write_reg_enable_s,
      flags_reg_enable    => flags_reg_enable_s,
      decoded_instruction => decoded_instruction_s,
      zero_op             => zero_op_s,
      neg_op              => neg_op_s,
      unsigned_overflow   => unsigned_overflow_s,
      signed_overflow     => signed_overflow_s,
      ram_addr            => addr,
      data_out            => data_out,
      data_in             => data_in
    );
end rtl;

