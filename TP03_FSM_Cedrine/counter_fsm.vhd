library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
-- importer unsigned et autres
use ieee.numeric_std.all;


entity counter_unit is
   generic(
    limit : positive
   );
   port ( 
    clock		: in std_logic; 
    resetn		: in std_logic; 
    end_counter	: out std_logic
    
    --LED      	: out std_logic;
    --restart     : in std_logic
    );
end counter_unit;

architecture behavioral of counter_unit is
	
	--Declaration des signaux internes 
--	constant Countlimit : positive := 199_999_999; -- 199_999_999 car 200_000_000 mais un bit de moins car commence a 0
--	-- Test pour testbench sur un count de 0 a 4
--	constant tb_Countlimit : positive := 4; --sert a faire des tests pour limiter ressources, temps et mieux voir
	-- Valeur maximal de comptage du compteur
    constant MAX : positive := limit; --200_000_000
    --constant MAX : positive := 200_000_000;
	signal Q : std_logic_vector (27 downto 0) := (others => '0');
	signal Cmd_resetn : std_logic;
	-- liaison entre XOR et D (bascule T)
	-- end_counter etant une sortie, il faut un signal interne pour pouvoir l'utiliser en entree
	signal end_counter_in : std_logic;
	begin

		--Partie sequentielle
		process(clock,resetn)
		begin
		    
		    --Quand resetn passe à 1, alors tous les bits de Q sont remis à zéro
			if(resetn = '1') then 
			     Q <= (others => '0');
			
			--Sinon si on est sur un coup d'horloge front montant, alors que la commande Cmd_reset est à 1, alors tous les bits de Q ainsi que la LED sont remis à zéro
			elsif(rising_edge(clock)) then
                if (Cmd_resetn = '1') then
                    Q <= (others => '0');
                
                --Sinon Q s'incrémente de 1
                else 
                    Q <= Q + 1;
                
                end if;
			end if;
		end process;
		
		--Partie combinatoire
		-- fonctionne en simultane
		Cmd_resetn <= '1' when end_counter_in = '1' --OR restart = '1' 
		else '0' ;
		
		end_counter_in <= '1' when Q = std_logic_vector(TO_UNSIGNED (MAX,28)) 
		else '0';
		end_counter <= end_counter_in;
		
		
						

end behavioral;