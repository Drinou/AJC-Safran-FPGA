library ieee;
use ieee.std_logic_1164.all;
--ajout de librairie pour unsigned et autres
use ieee.numeric_std.all;

entity tb_tp_fsm is
end tb_tp_fsm;

architecture behavioral of tb_tp_fsm is
    --Assignation des signaux d'entrée et de sortie et de leur valeur par défauts

	signal resetn        : std_logic := '0';
	signal clock         : std_logic := '0';
	signal end_counter_cycles : std_logic := '0';
	--signal LED         : std_logic := '0';
	--signal restart     : std_logic := '0';
	
	--Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      -- demi periode de 5ns
	constant period : time := 2*hp;  -- periode de 10ns, soit une frequence de 100Hz
	
	--Declaration de l'entite a tester
	component tp_fsm
	--Ajout du limit pour correspondre au counter_unit du counter.vhd
	   generic(
        limit : std_logic_vector (2 downto 0) := "110";
        limit_combi : positive := 3 --199_999_999
       );
	   port ( 
        clock		: in std_logic; 
        resetn		: in std_logic; 
        end_counter_cycles : out std_logic
        --LED         : out std_logic;
        --restart     : in std_logic
	   );
	end component;
	
	
	begin
	
	--Affectation des signaux du testbench avec ceux de l'entitée a tester
	uut: tp_fsm
	    --
	    generic map (
	       limit => "110"
	    )
        port map (
            clock => clock, 
            resetn => resetn, 
            end_counter_cycles => end_counter_cycles
            --LED => LED,
            --restart => restart
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clock <= not clock;
	end process;
	
    --Début du process
	process
	begin        
	   
	     -- un reset est effectué en début de code
	     resetn <= '1';
	     
	   	-- hold reset state for 100 ns.
	     --wait for 100 ns;
	     wait for period*10; 
	     
	     resetn <= '0';
	
	     wait;

	     -- attente pendant 20 periodes
--	     wait for 20*period;
	     
	     
--	     -- valeurs des sorties attendues :
	     
--	     assert end_counter_tb = '1'
--	        report "test failed for end_counter = 1" severity error;
	     
--	     assert LED = '1'
--	        report "test failed for LED = 1" severity error;
	        
--	     -- attente pendant 10 periodes pour réguler l'exécution du code et eviter les erreurs
--	     wait for 10*period;
	        
--	     assert end_counter_tb = '0'
--	        report "test failed for end_counter = 0" severity error;
	     
--	     assert LED = '0'
--	        report "test failed for LED = 0" severity error;
	        
--	     wait for 30*period;
	     
--	     assert end_counter_tb = '1'
--	        report "test failed for end_counter = 1" severity error;
	        
--	     assert LED = '1'
--	        report "test failed for LED = 1" severity error;

	   
	end process;
	
	
end behavioral;