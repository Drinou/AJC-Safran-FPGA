library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_Led_driver is
end tb_Led_driver;

architecture Behavioral of tb_Led_driver is

    --Assignation des signaux d'entrée et de sortie et de leur valeur par défauts
	signal clock           : std_logic := '0';
	signal resetn          : std_logic := '0';
	signal color_code      : std_logic_vector (1 downto 0) := (others => '0');
    signal update          : std_logic := '0';
    signal led_out_rouge   : std_logic := '0'; 
    signal led_out_verte   : std_logic := '0';
    signal led_out_bleue   : std_logic := '0';
    signal end_cycle       : std_logic := '0';

	--Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      -- demi periode de 10ns
	constant period : time := 2*hp;  -- periode de 20ns, soit une frequence de 100Hz
	
	--Declaration de l'entite a tester
	component Led_driver 
	--Ajout du limit pour correspondre au Led_driver du Led_driver.vhd
	   generic(
        limit_combi : positive
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
	end component;


    begin
	
	--Affectation des signaux du testbench avec ceux de l'entitée a tester
	uut: Led_driver
	    --
	    generic map (
	       limit_combi => 5 --(199_999_999)
	    )
        port map (
            clock => clock, 
            resetn => resetn,
            color_code => color_code,
            update => update, 
            led_out_rouge => led_out_rouge,
            led_out_verte => led_out_verte,
            led_out_bleue => led_out_bleue,
            end_cycle => end_cycle
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
		clock <= NOT clock;
	end process;
	
	process
	begin
		wait for 5*period;
		update <= NOT update;
	end process;
	
	-- this process is used to change the color code each 60ns (6 periods)
    -- to test the behaviour of the led_driver unit
    color_code_tester : process
        variable color_code_period : time := 6 * period;
    begin

        color_code <= "01"; -- red code
        wait for color_code_period;

        color_code <= "10"; -- green code
        wait for color_code_period;

        color_code <= "11"; -- blue code
        wait for color_code_period;

        color_code <= "00"; -- leds off
        wait for color_code_period;

    end process color_code_tester;
	
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



