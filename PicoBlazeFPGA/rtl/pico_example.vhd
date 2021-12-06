--------------------------------------------------------------------------------
-- Universidad Autonoma de Madrid
-- Escuela Politecnica Superior
-- Laboratorio de DIE
--------------------------------------------------------------------------------
-- Block: pico_example
--
-- Author: (UAM)
--
-- Description:
--   Top level of a PicoBlaze-based design example targeting the Zybo board.
--   Three PicoBlaze peripherals are included: one for accessing the switches,
--   pushbuttons and leds of the board, other for generating periodic interviews
--   and an example of maths coprocessor.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

--------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------

entity pico_example is
   port (
      -- Clock and reset
      Clk    : in std_logic; -- 125 MHz when taken from Zybo's oscillator
      XReset : in std_logic; -- Asynchronous, active high
      -- User interface signals:
      Switch  : in  std_logic_vector (3 downto 0); -- Switches
      Button  : in  std_logic_vector (3 downto 0); -- Pushbuttons
      Led     : out std_logic_vector (3 downto 0)  -- LEDs
   );
end pico_example;

--------------------------------------------------------------------------------
-- Architecture
--------------------------------------------------------------------------------

architecture structural of pico_example is

----------------------------------------------
-- Component declarations
----------------------------------------------

   -- PicoBlaze 8-bit microprocessor:
   component kcpsm3
      port (    address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
   end component;

   -- Program ROM for PicoBlaze:
   component rom_prog
      port (      address : in std_logic_vector(9 downto 0);
              instruction : out std_logic_vector(17 downto 0);
                      clk : in std_logic);
   end component;  

   -- Reset input adaptation (anti-metastability and synchronization):
   component reset_adapt
      generic (
         META_DEPTH : integer := 3
      );
      port (
         -- Clock and external reset inputs:
         Clk      : in  std_logic;
         ResetIn  : in  std_logic;
         -- Synchronized reset output:
         ResetOut : out std_logic
      );
   end component;
   
   -- Address decoder to select the desired peripheral:  
   component decoder
      port (
         -- Port address from microprocessor:
         PortId : in  std_logic_vector (7 downto 0);
         -- Selection output to peripherals:
         Sel    : out std_logic_vector (2 downto 0)
      );
   end component;
      
   -- Read data muxing, from peripherals to PicoBlaze:
   component mux_rdata
      port (
         -- Input selection bits and input read data buses:
         Sel      : in  std_logic_vector (2 downto 0);
         RDataIn0 : in  std_logic_vector (7 downto 0);
         RDataIn1 : in  std_logic_vector (7 downto 0);
         RDataIn2 : in  std_logic_vector (7 downto 0);
         -- Output read data buses:
         RDataOut : out std_logic_vector (7 downto 0)
      );
   end component;
  
   -- Periodic interrupt generation block:
   component gen_interrupt
      port (
         -- System signals
         Clk       : in std_logic;
         Reset     : in std_logic;
         -- Configuration Registers interface
         Sel       : in  std_logic;
         WriteEn   : in  std_logic;
         Address   : in  std_logic_vector (1 downto 0);
         WData     : in  std_logic_vector (7 downto 0);
         RData     : out std_logic_vector (7 downto 0);
         -- Interrupt interface:
         InterruptAck : in std_logic;
         Interrupt    : out std_logic
      );
   end component;
  
   -- Peripheral for accessing switches, pushbuttons and LEDs:  
   component sw_btn_leds is
      port (
         -- System signals
         Clk     : in  std_logic; -- System clock
         Reset   : in  std_logic; -- System asynchronous reset, active high
         -- Configuration Registers interface
         Sel     : in  std_logic;                     -- If 1, block is accessed
         WriteEn : in  std_logic;                     -- If 1, access is write
         Address : in  std_logic_vector (1 downto 0); -- Offset address of reg.
         WData   : in  std_logic_vector (7 downto 0); -- Write data
         RData   : out std_logic_vector (7 downto 0); -- Read data
         -- External Input/Output interface:
         Switch  : in  std_logic_vector (3 downto 0); -- Switches
         Button  : in  std_logic_vector (3 downto 0); -- Pushbuttons
         Led     : out std_logic_vector (3 downto 0)  -- LEDs
      );
   end component;
  
   -- Example of maths coprocessor:
   component copro is
      port (
         -- System signals
         Clk       : in  std_logic; -- System clock
         Reset     : in  std_logic; -- System asynchronous reset, active high
         -- Configuration Registers interface
         Sel       : in  std_logic;                     -- If 1, block is accessed
         WriteEn   : in  std_logic;                     -- If 1, access is write
         Address   : in  std_logic_vector (2 downto 0); -- Offset address of reg.
         WData     : in  std_logic_vector (7 downto 0); -- Write data
         RData     : out std_logic_vector (7 downto 0)  -- Read data
      );
   end component;
    
---------------------------------------------------
-- Declaration of internal signals:
---------------------------------------------------
   -- System:
   signal clk2         : std_logic; -- Internal clock, half the frequency of Clk
   signal reset        : std_logic; -- System reset(synched.)

   -- PicoBlaze signals:
   signal instAddress  : std_logic_vector (9 downto 0); -- Instruction address
   signal instruction  : std_logic_vector (17 downto 0);-- Instruction word
   signal portId       : std_logic_vector (7 downto 0); -- I/O port address
   signal writeStrobe  : std_logic;                     -- I/O write strobe
   signal outPort      : std_logic_vector (7 downto 0); -- I/O write data
   signal inPort       : std_logic_vector (7 downto 0); -- I/O read data
   signal interrupt    : std_logic;                     -- Interrupt signal
   signal interruptAck : std_logic;                     -- Int. acknowledgement

   -- I/O port address decoding and data muxing:
   signal sel          : std_logic_vector (2 downto 0); -- Select each block
   signal rData0_gint  : std_logic_vector (7 downto 0); -- Read data from peripheral 0 : gen_interrupr
   signal rData1_sbleds: std_logic_vector (7 downto 0); -- Read data from peripheral 1 : sw_btn_leds
   signal rData2_copro : std_logic_vector (7 downto 0); -- Read data from peripheral 2 : copro

---------------------------------------------------
-- Architecture body
---------------------------------------------------
    
begin
  
   -- Divide clock by 2:
   ---------------------
   
   i_bufr : bufr
      generic map (
         BUFR_DIVIDE => "2"
      )
      port map (
         CE => '1',
         CLR => '0',
         I => Clk,
         O => clk2
      );
  
   -- Instantiation of main components:
   ------------------------------------

   -- PicoBlaze 8-bit microprocessor:
   i_processor: kcpsm3
      port map (address => instAddress (9 downto 0),
            instruction => instruction (17 downto 0),
                port_id => portId (7 downto 0),
           write_strobe => writeStrobe,
               out_port => outPort (7 downto 0),
            read_strobe => open,
                in_port => inPort (7 downto 0),
              interrupt => interrupt,
          interrupt_ack => interruptAck,
                  reset => reset,
                    clk => clk2);

   -- Program ROM for PicoBlaze:
   i_rom : rom_prog
      port map (address     => instAddress (9 downto 0),
                instruction => instruction (17 downto 0),
                clk         => clk2);

   -- Reset input adaptation (anti-metastability and synchronization):
   i_reset_adapt : reset_adapt
      port map (
         -- Clock and external reset inputs:
         Clk      => clk2,
         ResetIn  => XReset,
         -- Synchronized reset output:
         ResetOut => reset
      );

   -- Address decoder to select the desired peripheral:  
   i_decoder : decoder
      port map  (
         -- Port address from microprocessor:
         PortId  => 
         -- Selection output to peripherals:
         Sel     => 
      );
  
   -- Read data muxing, from peripherals to PicoBlaze:  
   i_mux_rdata : mux_rdata
      port map (
         -- Input selection bits and input read data buses:
         Sel      => 
         RDataIn0 => 
         RDataIn1 => 
         RDataIn2 => 
         -- Output read data buses:
         RDataOut => 
      );

   -- Periodic interrupt generation block:
   i_gen_int : gen_interrupt
      port map (
         -- System signals
         Clk          => clk2,
         Reset        => reset,
         -- Configuration Registers interface
         Sel          => 
         WriteEn      => 
         Address      => 
         WData        => 
         RData        => 
         -- Interrupt interface:
         InterruptAck => 
         Interrupt    => 
      );
   
   -- Switches, pushbuttons and LEDs I/O interface:
   i_sw_btn_leds : sw_btn_leds
      port map (
         -- System signals
         Clk     => clk2,
         Reset   => reset,
         -- Configuration Registers interface
         Sel     => 
         WriteEn => 
         Address => 
         WData   => 
         RData   => 
         -- External Input/Output interface:
         Switch  => 
         Button  => 
         Led     => 
      );

   -- Coprocessor example:
   i_copro : copro
      port map (
         -- System signals
         Clk     => clk2,
         Reset   => reset,

         -- Configuration Registers interface
         Sel     =>
         WriteEn =>
         Address =>
         WData   =>
         RData   =>
      );
  
end structural;

