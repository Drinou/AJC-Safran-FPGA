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

entity Led_driver is
    generic (
        -- limit de comptagne sur 3 bits pour faire 6 boucles ('downto' = bit de point fort (à gauche) vs 'to' = bit de point faible (à droite))
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
        led_out_bleue   : out std_logic;
        end_cycle       : out std_logic
     );
end Led_driver;

architecture Behavioral of Led_driver is
    type state is (etat_init_on, etat_off); --Etats de la FSM
    signal present_state: state;
    -- constant counter_count_limit : positive := 6;
    -- constant counter_unit_limit : positive := 199_999_999;
--    signal current_state : state;  --etat dans lequel on se trouve actuellement
--    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    signal end_tempo : std_logic;
    
    signal mux_tempo_cycle : std_logic_vector (1 downto 0);
    signal mux_end_tempo : std_logic_vector (1 downto 0);
    signal end_tempo_cycle : std_logic_vector (1 downto 0);
    signal cmp_end_tempo_cycle : std_logic;
    signal cmd_end_cycle : std_logic;
    
    signal led_on_off : std_logic;
    
    signal mux_couleur_led : std_logic_vector(2 downto 0); 
    signal mux_update_couleur_led : std_logic_vector(2 downto 0);
    signal couleur_led_out : std_logic_vector(2 downto 0);
    
    signal couleur_led_rouge : std_logic;
    signal couleur_led_verte : std_logic;
    signal couleur_led_bleue : std_logic;
    
    --importation du composant "entity counter_unit" du counter.vhd
    component counter_unit is
        generic(
            limit : positive
        );
        port ( 
            clock		: in std_logic; 
            resetn		: in std_logic;
            end_counter	: out std_logic
        );
    end component;
	
begin
    --instanciation de la boite "component counter_unit"
    counter_unit_inst : counter_unit
        generic map (
            limit => limit_combi --counter_unit_limit
            )
        port map (
            clock => clock,
            resetn => resetn,
            end_counter => end_tempo
            );
    
    
    process(clock,resetn)
    begin
             
        --Quand resetn est a 1, alors tous les bits de counter_count sont remis à zéro
        if(resetn = '1') then 
           -- end_tempo <= '0'; -- BETISE !!!
            present_state <= etat_init_on; --Etat d'initialisation & au reset de la FSM
            led_on_off <= '1';
            couleur_led_out <= (others => '0');
            end_tempo_cycle <= (others => '0');
            
        
        --Sinon si on est sur un coup d'horloge front montant, alors counter_count prend la valeur de mux_incremt_2
        elsif(rising_edge(clock)) then

            case present_state is
            
                when etat_init_on =>  --Quand l'état est allumé 
                    led_on_off <= '1';
                    if(end_tempo ='1') then
                        present_state <= etat_off;
                    else
                        present_state <= etat_init_on;
                    end if;
                     
                when etat_off =>       --Quand l'état est éteint
                    led_on_off <= '0';
                    if(end_tempo ='1') then
                        present_state <= etat_init_on;
                    else
                        present_state <= etat_off;
                    end if;
             end case;
             
            couleur_led_out <= mux_update_couleur_led;
            
            end_tempo_cycle <= mux_end_tempo;

            
--            if (color_code = "00") then
--                mux_couleur_led <= "001"
--            elsif (color_code = "01") then 
--                mux_couleur_led <= "010"
--            elsif (color_code = "10") then
--                mux_couleur_led <= "100"
--            else (color_code = "11") then
--                mux_couleur_led <= "000"
--            end if;
            
        end if;  
    end process;
        
        mux_couleur_led <= "001" when color_code = "00" else 
        "010" when color_code = "01" else 
        "100" when color_code = "10" else 
        "000" when color_code = "11";
        
        mux_update_couleur_led <= mux_couleur_led when update = '1'
        else couleur_led_out;
        
        couleur_led_rouge <= couleur_led_out(0);
		couleur_led_verte <= couleur_led_out(1);
		couleur_led_bleue <= couleur_led_out(2);
        
        led_out_rouge <= couleur_led_rouge AND led_on_off;
		led_out_verte <= couleur_led_verte AND led_on_off;
		led_out_bleue <= couleur_led_bleue AND led_on_off;
		
--		led_out_rouge <= couleur_led_out(0) AND led_on_off; -- moins de ligne de code, plus opti
--		led_out_verte <= couleur_led_out(1) AND led_on_off;
--		led_out_bleue <= couleur_led_out(2) AND led_on_off;
        
        mux_tempo_cycle <= end_tempo_cycle when end_tempo = '0'
        else end_tempo_cycle + '1';
        mux_end_tempo <= mux_tempo_cycle when cmd_end_cycle = '0'
        else (others => '0');
        cmp_end_tempo_cycle <= '1' when end_tempo_cycle = "10" -- end_tempo_cycle = 2 en binaire donc 10
        else '0';
        cmd_end_cycle <= cmp_end_tempo_cycle;
        end_cycle <= cmp_end_tempo_cycle;

        


end Behavioral;


