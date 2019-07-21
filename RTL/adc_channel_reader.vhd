--------------------------------------------------------------------------------
--
--   FileName:         spi_master.vhd
--   Dependencies:     none
--   Design Software:  Quartus II Version 9.0 Build 132 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 7/23/2010 Scott Larson
--     Initial Public Release
--   Version 1.1 4/11/2013 Scott Larson
--     Corrected ModelSim simulation error (explicitly reset clk_toggles signal)
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

LIBRARY work;
use work.pkg_adc.all;
use work.pkg_apb3.all;

ENTITY adc_channel_reader IS
  PORT(
    clk_spi : IN std_logic;
    cs_spi : out std_logic;
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    miso    : IN     STD_LOGIC;                             --master in, slave out
    mosi    : OUT    STD_LOGIC;                             --master out, slave in

      apb3_master : in apb3;
      apb3_master_Back : out apb3_Back
);
END adc_channel_reader;

ARCHITECTURE logic OF adc_channel_reader IS
    constant device_add : STD_LOGIC_VECTOR(1 downto 0) :="01" ; 
  TYPE machine IS(ready, execute);
   signal adc_channel :     apb3_Reg_array(5 downto 0); --data received


signal channel_count_int: integer  range 0 to 6  ;                         --state machine data type
signal access_counter_int: integer  range 0 to 63;                           --state machine data type
  SIGNAL channel_count   : STD_LOGIC_VECTOR(2 DOWNTO 0); --transmit data buffer
  SIGNAL access_counter   : STD_LOGIC_VECTOR(5 DOWNTO 0); --transmit data buffer
signal buffer_rx : std_logic_vector(31 downto 0);
  Signal Channel_change: std_logic;
  Signal clock: std_logic;
  BEGIN
  clock<=not clk_spi;

  PROCESS(clock, reset_n)
  BEGIN

    IF(reset_n = '0') THEN        --reset system
        access_counter_int<=0;
    ELSIF(clock'EVENT AND clock = '1') THEN
        if access_counter_int<60 then
        access_counter_int<=access_counter_int+1; 
        else    
        access_counter_int<=0;
end if;
    end if;
  END PROCESS;

  PROCESS(clock, reset_n)

  BEGIN

    IF(reset_n = '0') THEN        --reset system
            channel_count_int<=0;

    ELSIF(clock'EVENT AND clock = '1') THEN
        if (Channel_change='1' and channel_count_int<5) then
            channel_count_int<=channel_count_int+1;
            adc_channel(channel_count_int)<=buffer_rx;
        elsif (Channel_change='1' and channel_count_int>=5)then

            adc_channel(5)<=buffer_rx;
            channel_count_int<=0;

        end if;
    end if;
  END PROCESS;
channel_count<=std_logic_vector(to_unsigned(channel_count_int,channel_count'length));
access_counter<=std_logic_vector(to_unsigned(access_counter_int,access_counter'length));

  PROCESS(clock, reset_n)
  BEGIN
    IF(reset_n = '0') THEN        --reset system
        Channel_change<='0';
        cs_spi<='1';

    ELSIF(clock'EVENT AND clock = '1') THEN
        if (  access_counter<10) then
            cs_spi<='1';
            mosi<='0';
        elsif(access_counter=10) then
            cs_spi<='0';
            mosi<=device_add(1);
            Channel_change<='1';

        elsif(access_counter=11)then
            buffer_rx<=(others=>'0');

            Channel_change<='0';

            mosi<=device_add(0);
        elsif(access_counter=12)then
            mosi<='0';
        elsif(access_counter=13)then
            mosi<='0';
        elsif(access_counter=14)then
            mosi<=channel_count(2);
        elsif(access_counter=15)then
            mosi<=channel_count(1);
        elsif(access_counter=16)then
            mosi<=channel_count(0);
        elsif(access_counter=17)then
            mosi<='1';
        elsif(access_counter>=18 and access_counter<=34)then
            mosi<='0';
            buffer_rx(34-access_counter_int)<=miso;
        else 
            cs_spi<='1';
            mosi<='0';

    end if;
    end if;
  

  end PROCESS;
apb3_reader_sr04 : entity work.apb3_reader 
generic map( 
        Number_Reg => 6,
        REG_DEFINITION =>(R,R,R,R,R,R)
)
port map(
      reset =>reset_n,
      apb3_master =>apb3_master,
      apb3_master_Back =>apb3_master_Back,

      Regs_In =>adc_channel,
      Regs_Out=>open

);

END logic;
