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
	constant Countlimit : positive := 200_000_000; -- 199_999_999 car un bit de moins si commence � 0
	-- Test pour testbench sur un count de 0 � 4
	constant tb_Countlimit : positive := 4; --sert � faire des tests pour limiter ressources, temps et mieux voir
	-- Valeur maximal de comptage du compteur
    constant MAX : positive := tb_Countlimit; --200_000_000
    --constant MAX : positive := 200_000_000;
	signal Q : std_logic_vector (27 downto 0) := (others => '0');
	signal Cmd_resetn : std_logic;
	-- liaison entre XOR et D (bascule T)
	signal memoxor : std_logic;
	-- liaison entre Q et LED (registre)
	signal memoled : std_logic;
	-- end_counter �tant une sortie, il faut un signal interne pour pouvoir l'utiliser en entr�e (pour la LED)
	signal end_counter_in : std_logic;
	begin

		--Partie sequentielle
		process(clock,resetn)
		begin
		    
		    --Quand resetn passe � 1, alors tous les bits de Q sont remis � z�ro
			if(resetn = '1') then 
			     Q <= (others => '0');
			     memoled <= '0';
			
			--Sinon si on est sur un coup d'horloge front montant, alors que la commande Cmd_reset est � 1, alors tous les bits de Q ainsi que la LED sont remis � z�ro
			elsif(rising_edge(clock)) then
                if (Cmd_resetn = '1') then
                    Q <= (others => '0');
                
                --Sinon Q s'incr�mente de 1
                else 
                    Q <= Q + 1;
                
                end if;
                
                -- liaison entre Q et LED
                memoled <= memoxor;
                
			end if;
		end process;
		
		--Partie combinatoire
		-- fonctionne en simultané
		Cmd_resetn <= '1' when end_counter_in = '1' /* ce qui est égale à '1' when Q = MAX*/  OR restart = '1' 
		else '0' ;
		
		end_counter_in <= Cmd_resetn;
		end_counter <= end_counter_in;
		
		memoxor <= end_counter_in XOR memoled;
		LED <= memoled;
						

end behavioral;