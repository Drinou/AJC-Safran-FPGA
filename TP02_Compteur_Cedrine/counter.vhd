library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity counter_unit is
    port ( 
		clock		: in std_logic; 
        resetn		: in std_logic; 
        end_counter	: out std_logic;
        LED      	: out std_logic;
        restart     : in std_logic
     );
end counter_unit;

architecture behavioral of counter_unit is
	
	--Declaration des signaux internes 
	constant Countlimit : positive := 200_000_000; -- 199_999_999 car un bit de moins si commence à 0
	-- Test pour testbench sur un count de 0 à 4
	constant tb_Countlimit : positive := 4; --sert à faire des tests pour limiter ressources, temps et mieux voir
	-- Valeur maximal de comptage du compteur
    constant MAX : positive := tb_Countlimit; --200_000_000
    --constant MAX : positive := 200_000_000;
	signal Q : std_logic_vector (27 downto 0) := (others => '0');
	signal Cmd_resetn : std_logic;
	-- liaison entre XOR et D (bascule T)
	signal memoxor : std_logic;
	-- liaison entre Q et LED (registre)
	signal memoled : std_logic;
	-- end_counter étant une sortie, il faut un signal interne pour pouvoir l'utiliser en entrée (pour la LED)
	signal end_counter_in : std_logic;
	begin

		--Partie sequentielle
		process(clock,resetn)
		begin
		    
		    --Quand resetn passe à 1, alors tous les bits de Q sont remis à zéro
			if(resetn = '1') then 
			     Q <= (others => '0');
			     memoled <= '0';
			
			--Sinon si on est sur un coup d'horloge front montant, alors que la commande Cmd_reset est à 1, alors tous les bits de Q ainsi que la LED sont remis à zéro
			elsif(rising_edge(clock)) then
                if (Cmd_resetn = '1') then
                    Q <= (others => '0');
                
                --Sinon Q s'incrémente de 1
                else 
                    Q <= Q + 1;
                
                end if;
                
                -- liaison entre Q et LED
                memoled <= end_counter_in XOR memoled;
                
			end if;
		end process;
		
		--Partie combinatoire
		-- fonctionne en simultaner
		Cmd_resetn <= '1' when Q = MAX OR restart = '1' 
		else '0' ;
		
		end_counter_in <= Cmd_resetn;
		end_counter <= end_counter_in;
		
		memoxor <= end_counter_in XOR memoled;
		LED <= memoled;
						

end behavioral;