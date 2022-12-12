-- ATENCAO: O Banco de registradores eh sensivel aa borda de descida do clock
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bancoRegistradores is
	generic(
		numBitsDefineReg: positive;
		larguraRegistrador: positive
	);
	port(
		clock,  reset: in std_logic;
		RegASerLido1, RegASerLido2, RegASerEscrito: in std_logic_vector(numBitsDefineReg-1 downto 0);
		DadoDeEscrita: in std_logic_vector(larguraRegistrador-1 downto 0);
		EscReg: in std_logic;
		DadoLido1, DadoLido2: out std_logic_vector(larguraRegistrador-1 downto 0)
	);
end entity;

architecture comportamento of bancoRegistradores is
	type TipoVetorRegistradores is array(0 to 2**numBitsDefineReg-1) of std_logic_vector(larguraRegistrador-1 downto 0);
	
	signal reg: TipoVetorRegistradores;
	--signal zero: TipoVetorRegistradores

begin
    -- LP
    -- COMPLETE

    escrita: process(clock, escreg, reset) is
    begin
		if reset = '1' then
			for i in reg'range loop
				reg(i) <= (others=>'0');
			end loop;
		


		elsif falling_edge(clock) and escreg='1' then
			reg(to_integer(unsigned(regaserescrito))) <= dadodeescrita;
		end if;


	end process;
    -- LS
	-- COMPLETE
	leitura: process(reg,regaserlido1, regaserlido2) is
    begin
		dadolido1 <= reg(to_integer(unsigned(regaserlido1)));
		dadolido2 <= reg(to_integer(unsigned(regaserlido2)));	
	end process;
end architecture;
