library ieee;
use ieee.std_logic_1164.all;

entity datapath is
	port(
	    -- control inputs
	    clock, clock_ram, reset: in std_logic;
		RegDst, DvCeq, DvCne, DvI, LerMem, MemParaReg, EscMem, ULAFonte, EscReg: in std_logic;
		ULAOp: in std_logic_vector(1 downto 0);
        -- control outputs
		Opcode: out std_logic_vector(5 downto 0);
		-- externalizando saídas das memorias, do banco de registradores e da ULA (PARA TESTES)
		InstrucaoLida, DadoLido, RegLido1, RegLido2, ULAResultado: out std_logic_vector(31 downto 0)
	);
end entity;

architecture estrutura of datapath is
	COMPONENT multiplexer2x1 IS
		GENERIC (width : POSITIVE);
		PORT (
			input0, input1 : IN STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
			sel : IN STD_LOGIC;
			output : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0));
	END COMPONENT;
	COMPONENT addersubtractor IS
		GENERIC (
			N : POSITIVE;
			isAdder : BOOLEAN;
			isSubtractor : BOOLEAN);
		PORT (
			op : IN STD_LOGIC;
			a, b : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			result : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			ovf, cout : OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT registerN IS
		GENERIC (
			width : NATURAL;
			resetValue : INTEGER := 0);
		PORT (
			clock, reset, load : IN STD_LOGIC;
			input : IN STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0));
	END COMPONENT;
	COMPONENT ramInstrucoes IS
		GENERIC (
			datawidth: positive := 32; -- deixe sempre em 32 para o projeto do MIPS
			addresswidth: positive := 32 -- deixe sempre em 32 para o projeto do MIPS (esse valor sera simplesmente ignorado)
		);
		PORT (
			-- control in
			ck, reset, readd, writee : IN STD_LOGIC;
			-- data in
			datain : IN STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0);
			address : IN STD_LOGIC_VECTOR(addresswidth - 1 DOWNTO 0);
			-- controll out
			dataout : OUT STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ramDados IS
		GENERIC (
			datawidth: positive := 32; -- deixe sempre em 32 para o projeto do MIPS
		addresswidth: positive := 32 -- deixe sempre em 32 para o projeto do MIPS (esse valor sera simplesmente ignorado)
		);
		PORT (
			-- control in
			ck, reset, readd, writee : IN STD_LOGIC;
			-- data in
			datain : IN STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0);
			address : IN STD_LOGIC_VECTOR(addresswidth - 1 DOWNTO 0);
			-- controll out
			dataout : OUT STD_LOGIC_VECTOR(datawidth - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT deslocador IS
		GENERIC (
			larguraDados : POSITIVE;
			numBitsDeslocar : INTEGER;
			deslocaParaDireita : BOOLEAN;
			deslocaParaEsquerda : BOOLEAN
		);
		PORT (
			Entrada : IN STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
			direcao : IN STD_LOGIC; --0: deslocaParaDireita, 1: deslocaParaEsquerda
			Saida : OUT STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT extensaoSinal IS
		GENERIC (
			larguraSaida : INTEGER;
			larguraEntrada : INTEGER);
		PORT (
			entrada : IN STD_LOGIC_VECTOR(larguraEntrada - 1 DOWNTO 0);
			saida : OUT STD_LOGIC_VECTOR(larguraSaida - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT bancoRegistradores IS
		GENERIC (
			numBitsDefineReg : POSITIVE;
			larguraRegistrador : POSITIVE
		);
		PORT (
			clock,  reset: in std_logic;
			RegASerLido1, RegASerLido2, RegASerEscrito: in std_logic_vector(numBitsDefineReg-1 downto 0);
			DadoDeEscrita: in std_logic_vector(larguraRegistrador-1 downto 0);
			EscReg: in std_logic;
			DadoLido1, DadoLido2: out std_logic_vector(larguraRegistrador-1 downto 0)
		);
	END COMPONENT;
	COMPONENT operacaoULA IS
		PORT (
			ULAOp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ULA IS
		GENERIC (width : POSITIVE);
		PORT (
			op : IN STD_LOGIC_VECTOR(2 DOWNTO 0); --000:AND , 001:OR , 010:ADD, 110:SUB, 111:SLT
			a, b : IN STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
			zero : OUT STD_LOGIC;
			res : OUT STD_LOGIC_VECTOR(width - 1 DOWNTO 0)
		);
	END COMPONENT;
    
    signal pc_in, pc_out, mux_esc_out,edata, ula_out,inst: std_logic_vector(31 downto 0);
	signal mux0_out: std_logic_vector(4 downto 0);
	signal mux_dados_out, mem_dados_out,mux_fonte_out,dadolido1, dadolido2, ext_sin_out: std_logic_vector(31 downto 0);
	signal ulaop_out: std_logic_vector(2 downto 0);
	signal zero: std_logic;
begin
    -- COMPLETE
	pc: registerN generic map(32, 0) port map(clock=>clock, reset=>reset, load=>'1', input=>pc_in, output=>pc_out);
	mem_instr: ramInstrucoes generic map(32, 32) port map(ck=>clock, reset=>'0', readd=>'1', writee=>'0', datain=>edata, address=>pc_out, dataout=>inst);
	opcode <= inst(31 downto 26);
	mux0: multiplexer2x1 generic map(5) port map(input0=>inst(20 downto 16), input1=>inst(15 downto 11), sel=>regdst, output=>mux0_out);
	bancoregistradores_inst: bancoRegistradores
	  generic map (
		numBitsDefineReg   => 5,
		larguraRegistrador => 32
	  )
	  port map (
		clock          => clock,
		reset          => reset,
		RegASerLido1   => inst(25 downto 21),
		RegASerLido2   => inst(20 downto 16),
		RegASerEscrito => mux0_out,
		DadoDeEscrita  => mux_dados_out,
		EscReg         => EscReg,
		DadoLido1      => DadoLido1,
		DadoLido2      => DadoLido2
	  );
	extensaosinal_inst: extensaoSinal
	  generic map (
		larguraSaida   => 32,
		larguraEntrada => 16
	  )
	  port map (
		entrada => inst(15 downto 0),
		saida   => ext_sin_out
	  );
	multiplexer2xx1_inst: multiplexer2x1
	  generic map (
		width => 32
	  )
	  port map (
		input0 => dadolido2,
		input1 => ext_sin_out,
		sel    => ulafonte,
		output => mux_fonte_out
	  );
	operacaoula_inst: operacaoULA
	  port map (
		ULAOp => ULAOp,
		Funct => inst(5 downto 0),
		op    => ulaop_out
	  );
	ula_inst: ULA
	  generic map (
		width => 32
	  )
	  port map (
		op   => ulaop_out,
		a    => dadolido1,
		b    => mux_fonte_out,
		zero => zero,
		res  => ula_out
	  );
	ramdados_inst: ramDados
	  generic map (
		datawidth    => 32,
		addresswidth => 32
	  )
	  port map (
		ck      => clock,
		reset   => reset,
		readd   => lermem,
		writee  => escmem,
		datain  => dadolido2,
		address => ula_out,
		dataout => mem_dados_out
	  );
	multiplexer2x1_inst: multiplexer2x1
	  generic map (
		width => 32
	  )
	  port map (
		input0 => ula_out,
		input1 => mem_dados_out,
		sel    => memparareg,
		output => mux_esc_out
	  );


end architecture;



    -- COMPLETE
--	pc: registerN generic map(32, 0) port map(clock=>clock, reset=>reset, load=>'1', input=>pc_in, output=>pc_out);
--	mem_instr: ramInstrucoes generic map(32, 32) port map(ck=>clock, reset=>'0', readd=>'1', writee=>'0', datain=>edata, address=>pc_out, dataout=>inst);
--	opcode <= inst(31 downto 26);
--	mux0: multiplexer2x1 generic map(5) port map(input0=>inst(20 downto 16), input1=>inst(15 downto 11), sel=>regdst, output=>mux0_out);
--	bancoregistradore