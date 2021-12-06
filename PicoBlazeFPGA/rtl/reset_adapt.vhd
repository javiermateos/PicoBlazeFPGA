--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: reset_adapt
--
-- Author: (UAM)
--
-- Description:
--   Synchronizes a external reset signal to generate the internal reset
--   signal, free of possible metastability and synchronous with the clock.
--   Reset assertion is asynchronous, deassertion is synchronous.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

entity reset_adapt is
  generic (
            META_DEPTH : integer := 3  -- Number of flops in anti-metastability
                                       --   chain. Optimum configuration
                                       --   depends on clock frequency.
          );
  port (
        -- Clock and external reset inputs:
        Clk      : in  std_logic;
        ResetIn  : in  std_logic;
        -- Synchronized reset output:
        ResetOut : out std_logic
       );
end reset_adapt;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture rtl of reset_adapt is
  -- Signal declaration for anti-metastability flip-flop chain:
  signal resetMeta : std_logic_vector (META_DEPTH-1 downto 0);
begin
  
  -- Anti-metastability (shift reset bit in):
  
  process (Clk)
  begin
    if Clk'event and Clk = '1' then
      resetMeta <= resetMeta(META_DEPTH-2 downto 0) & ResetIn;
    end if;
  end process;
    
  -- Assertion is asynchronous, deassertion is synchronous:
  
  ResetOut <= ResetIn or resetMeta(META_DEPTH-1);
  
    
end rtl;

