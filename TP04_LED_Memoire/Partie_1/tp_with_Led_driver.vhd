library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tp_with_Led_driver is
    generic (
        -- limit de comptagne sur 3 bits pour faire 6 boucles ('downto' = bit de point fort (à gauche) vs 'to' = bit de point faible (à droite))
        limit : std_logic_vector (2 downto 0) := "110";
        limit_combi : positive := 199_999_999
    );
    port ( 
        clock			: in std_logic; 
        resetn		    : in std_logic;
        
        button_0        : in std_logic;
        button_1        : in std_logic;
        
        led_out_rouge   : out std_logic; 
        led_out_verte   : out std_logic;
        led_out_bleue   : out std_logic
     );
end tp_with_Led_driver;

architecture Behavioral of tp_with_Led_driver is

    signal mux_color_code : std_logic_vector (1 downto 0);
    
    signal button_0_in : std_logic;
    signal button_0_out : std_logic;
    signal cmd_button_0 : std_logic;
    
    --importation du composant "entity counter_unit" du counter.vhd
    component Led_driver 
	--Ajout du limit pour correspondre au Led_driver du Led_driver.vhd
	   generic(
        limit : std_logic_vector (2 downto 0) := "110";
        limit_combi : positive := 199_999_999
       );
	   port ( 
        clock			: in std_logic; 
        resetn		    : in std_logic;
        color_code      : in std_logic_vector (1 downto 0);
        update          : in std_logic;
        led_out_rouge   : out std_logic; 
        led_out_verte   : out std_logic;
        led_out_bleue   : out std_logic
       );
    end component;

	
begin       
     --instanciation de la boite "component Led_driver"       
     led_driver_unit_inst : Led_driver
        generic map (
            limit => limit,
            limit_combi => limit_combi
            )
        port map (
            clock => clock,
            resetn => resetn,
            color_code => mux_color_code,
            update => cmd_button_0,
            led_out_rouge => led_out_rouge,
            led_out_verte => led_out_verte,
            led_out_bleue => led_out_bleue
            );
    
    
    process(clock,resetn)
    begin
             
        --Quand resetn est a 1, alors tous les bits de counter_count sont remis à zéro
        if(resetn = '1') then 
            button_0_in <= '0';
            button_0_out <= '0';
        
        --Sinon si on est sur un coup d'horloge front montant, alors counter_count prend la valeur de mux_incremt_2
        elsif(rising_edge(clock)) then
        button_0_in <= button_0;
		button_0_out <= button_0_in;
        end if;  
    end process;
        
		
		mux_color_code <= "10" when button_1 = '0'
		else "01";
		
		cmd_button_0 <= button_0_in AND NOT button_0_out;

end Behavioral;


