----------------------------------------------------------------------
-- Created by SmartDesign Tue Nov 14 14:10:41 2017
-- Version: v11.8 SP2 11.8.2.4
----------------------------------------------------------------------
 
library ieee;

use ieee.std_logic_1164.all;
Library work;

use work.pkg_apb3.all;
package pkg_adc is
 

type adc_channel_array is array ( 0 to 5 ) of std_logic_vector(31 downto 0);

component adc_channel_reader is port (
    clk_spi : IN std_logic;
    cs_spi : out std_logic;
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    enable  : IN     STD_LOGIC;                             --initiate transaction
    miso    : IN     STD_LOGIC;                             --master in, slave out
    mosi    : OUT    STD_LOGIC;                             --master out, slave in
      apb3_master : in apb3;
      apb3_master_Back : out apb3_Back
);
end component adc_channel_reader;
  
end package pkg_adc;