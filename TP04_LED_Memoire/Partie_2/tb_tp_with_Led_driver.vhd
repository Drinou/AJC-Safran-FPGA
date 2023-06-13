library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_tp_with_Led_driver is
end tb_tp_with_Led_driver;

architecture Behavioral of tb_tp_with_Led_driver is

    --Assignation des signaux d'entrée et de sortie et de leur valeur par défauts
	signal clock           : std_logic := '0';
	signal resetn          : std_logic := '0';
	
    signal button_0        : std_logic := '0';
    signal button_1        : std_logic := '0';
    
    signal led_out_rouge   : std_logic := '0'; 
    signal led_out_verte   : std_logic := '0';
    signal led_out_bleue   : std_logic := '0';

	--Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      -- demi periode de 10ns
	constant period : time := 2*hp;  -- periode de 20ns, soit une frequence de 100Hz
	
	--Declaration de l'entite a tester
	component tp_with_Led_driver 
	--Ajout du limit pour correspondre au Led_driver du Led_driver.vhd
	   generic(
        limit_combi : positive
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
	end component;


    begin
	
	--Affectation des signaux du testbench avec ceux de l'entitée a tester
	uut: tp_with_Led_driver
	    --
	    generic map (
	       limit_combi => 5 --(199_999_999)
	    )
        port map (
            clock => clock, 
            resetn => resetn,
            
            button_0 => button_0,
            button_1 => button_1, 
            
            led_out_rouge => led_out_rouge,
            led_out_verte => led_out_verte,
            led_out_bleue => led_out_bleue
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clock <= NOT clock;
	end process;
	
	process
	begin
		wait for 2*period;
		button_0 <= NOT button_0;
	end process;
	
		process
	begin
		wait for 6*period;
		button_1 <= NOT button_1;
	end process;
	
    --Début du process
	process
	begin        
	   
	     -- un reset est effectué en début de code
	     resetn <= '1';
	     
	   	-- hold reset state for 100 ns.
	     wait for 100 ns;
	     
	     resetn <= '0';
	
	     wait;

	end process;

end Behavioral;



