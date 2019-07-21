library ieee;

use ieee.std_logic_1164.all;

package pkg_adc is
 
 

  


type adc_channel_array is array ( 0 to 19 ) of std_logic_vector(31 downto 0);

 component adc_channel_reader is port (
    clk_spi : IN std_logic;
    cs_spi : out std_logic;
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    enable  : IN     STD_LOGIC;                             --initiate transaction
    miso    : IN     STD_LOGIC;                             --master in, slave out
    mosi    : OUT    STD_LOGIC;                             --master out, slave in
    adc_channel : OUT    adc_channel_array --data received
end component adc_channel_reader;
  
end package pkg_adc;
 
