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
        end_counter_cycles : out std_logic
     );
end tp_fsm;



architecture behavioral of tp_fsm is

--    type state is (idle, state1, state2); --a modifier avec vos etats
     -- constant counter_count_limit : positive := 6;
     -- constant counter_unit_limit : positive := 199_999_999;
--    signal current_state : state;  --etat dans lequel on se trouve actuellement
--    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
      signal cmd_incremt_counter : std_logic;
      signal mux_incremt_1 : std_logic_vector (2 downto 0):= (others => '0');
      signal mux_incremt_2 : std_logic_vector (2 downto 0):= (others => '0');
      signal counter_count : std_logic_vector (2 downto 0) := (others => '0');
      signal cmd_reinit_counter_cycles : std_logic;
      signal end_counter_cycles_in : std_logic;

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
    
    counter_count_p : process(clock,resetn)
    begin
             
        --Quand resetn est a 1, alors tous les bits de counter_count sont remis à zéro
        if(resetn = '1') then 
            counter_count <= (others => '0');
        
        --Sinon si on est sur un coup d'horloge front montant, alors que la commande Cmd_incremt_counter est à 1, alors counter_count s'incremente de 1
        elsif(rising_edge(clock)) then
            if (cmd_incremt_counter = '1') then
                mux_incremt_1 <= counter_count + 1;
            
            --Sinon counter_count reste a sa derniere valeure
            else 
                mux_incremt_1 <= counter_count;
            
            end if;
            
            if(cmd_reinit_counter_cycles = '1') then
               mux_incremt_2 <= (others => '0'); 
               
            else
                mux_incremt_2 <= mux_incremt_1;                                   
    
--                current_state <= idle;
         
--			   elsif(rising_edge(clock)) then
    
--				current_state <= next_state;
        
--				--a completer avec votre compteur de cycles
             end if;
        
         end if;
            
            
            
    end process counter_count_p;
		
			
		
--    -- FSM
--    fsm_p : process(current_state,XX) --a completer avec vos signaux
--    begin		
--       case current_state is
--          when idle =>
--            next_state <= state1; --prochain etat

--            --signaux pilotes par la fsm

--          when state1 =>
--            next_state <= state1;

--            --signaux pilotes par la fsm

--          when state2 =>
--            next_state <= state1;

--            --signaux pilotes par la fsm


--          end case;


--		end process fsm_p;
		
		end_counter_cycles_in <= '1' when counter_count = limit
		else '0';
		end_counter_cycles <= end_counter_cycles_in;
		cmd_reinit_counter_cycles <= '1' when end_counter_cycles_in = '1' --OR restart = '1' 
		else '0' ;	

end behavioral;