library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deslocador is
	generic(
		larguraDados: positive;
		numBitsDeslocar: integer;
		deslocaParaDireita: boolean;
		deslocaParaEsquerda: boolean
	);
	port(
		Entrada: in std_logic_vector(larguraDados-1 downto 0);
		direcao: in std_logic; --0: deslocaParaDireita, 1: deslocaParaEsquerda
		Saida: out std_logic_vector(larguraDados-1 downto 0)
	);
end entity;

architecture comportamento of Deslocador is
begin
    -- COMPLETE 
	esquerda: if deslocaparaesquerda and not deslocaparadireita generate
		saida <= std_logic_vector(shift_left(unsigned(entrada), numbitsdeslocar)); 
	end generate;   
	direita: if deslocaparadireita and not deslocaparaesquerda generate
		saida <= std_logic_vector(shift_right(unsigned(entrada), numbitsdeslocar)); 
	end generate;
	direitaesquerda: if deslocaparadireita and deslocaparaesquerda generate
		saida <= std_logic_vector(shift_left(unsigned(entrada), numbitsdeslocar)) when direcao = '1' else
				 std_logic_vector(shift_right(unsigned(entrada), numbitsdeslocar)) when direcao = '0';
	end generate;
end architecture;