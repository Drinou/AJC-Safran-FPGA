library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity tp_fsm is
    generic (
        -- limit de comptagne sur 3 bits pour faire 6 boucles ('downto' = bit de point fort (à gauche) vs 'to' = bit de point faible (à droite))
        limit : std_logic_vector (2 downto 0) := "110";
        limit_combi : positive := 199_999_999
    );
    port ( 
        clock			: in std_logic; 
        resetn		    : in std_logic;
        restart         : in std_logic;
        led1_out        : out std_logic_vector (2 downto 0);
        led2_out        : out std_logic_vector (2 downto 0)
     );
end tp_fsm;



architecture behavioral of tp_fsm is

    type state is (etat_init_W, etat_R, etat_B, etat_V); --Etats de la FSM
    signal present_state: state;
    -- constant counter_count_limit : positive := 6;
    -- constant counter_unit_limit : positive := 199_999_999;
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    signal cmd_incremt_counter : std_logic;
    signal mux_incremt_1 : std_logic_vector (2 downto 0):= (others => '0');
    signal mux_incremt_2 : std_logic_vector (2 downto 0):= (others => '0');
    signal counter_count : std_logic_vector (2 downto 0) := (others => '0');
    signal cmd_reinit_counter_cycles : std_logic;
    signal end_counter_cycles : std_logic;
    signal led1_RVB : std_logic_vector (2 downto 0);
    signal led2_RVB : std_logic_vector (2 downto 0);
    signal cmd_blink : std_logic;
    signal blink : std_logic;
    signal mux_blink : std_logic;
    
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
            end_counter => cmd_incremt_counter
            );
    
    
    process(clock,resetn)
    begin
             
        --Quand resetn est a 1, alors tous les bits de counter_count sont remis à zéro
        if(resetn = '1') then 
            counter_count <= (others => '0');
            led1_RVB <= (others => '0');
            led2_RVB <= (others => '0');
            blink <= '0';
            present_state <= etat_init_W; --Etat d'initialisation & au reset de la FSM
        
        --Sinon si on est sur un coup d'horloge front montant, alors counter_count prend la valeur de mux_incremt_2
        elsif(rising_edge(clock)) then
            counter_count <= mux_incremt_2; --signal interne en sortie du registe entre Q et =
            blink <= mux_blink; --signal interne en sortie du mux du registre de blink
            case present_state is
            
                when etat_init_W =>  --Quand l'état est Blanc
                    led1_RVB(0) <= '1';
                    led1_RVB(1) <= '1';
                    led1_RVB(2) <= '1';
                    if(end_counter_cycles ='1') then
                        present_state<= etat_R;
                    elsif(restart ='1') then
                    present_state<= etat_init_W;
                    end if;
                     
                when etat_R =>        --Quand l'état est Rouge
                    led1_RVB(0) <= '1';
                    led1_RVB(1) <= '0';
                    led1_RVB(2) <= '0';
                    if(end_counter_cycles ='1') then
                        present_state<= etat_B;
                    elsif(restart ='1') then
                    present_state<= etat_init_W;
                    end if;
                    
                when etat_B =>       --Quand l'état est Bleu
                    led1_RVB(0) <= '0';
                    led1_RVB(1) <= '1';
                    led1_RVB(2) <= '0';
                    if(end_counter_cycles ='1') then
                        present_state<= etat_V;
                    elsif(restart ='1') then
                    present_state<= etat_init_W;
                    end if;
                    
                when etat_V =>         --Quand l'état est Vert
                    led1_RVB(0) <= '0';
                    led1_RVB(1) <= '0';
                    led1_RVB(2) <= '1';
                    if(end_counter_cycles ='1') then
                        present_state<= etat_R;
                    elsif(restart ='1') then
                    present_state<= etat_init_W;
                    end if;
            end case;
         end if;  
    end process;


        mux_incremt_1 <= counter_count + 1 when cmd_incremt_counter = '1'
        else counter_count;
        
        mux_incremt_2 <= mux_incremt_1 when cmd_reinit_counter_cycles = '0'
        else (others => '0'); -- ou "000"
        
		end_counter_cycles <= '1' when counter_count = limit
		else '0';
		
		cmd_reinit_counter_cycles <= end_counter_cycles; --OR restart = '1'	
		
		cmd_blink <= cmd_incremt_counter;
		
		mux_blink <= blink when cmd_blink = '0'
        else NOT blink;
		
		led1_out <= led1_RVB when blink = '1'
		else (others => '0');
        
        led2_out <= led2_RVB when blink = '1'
		else (others => '0');
        
end behavioral;