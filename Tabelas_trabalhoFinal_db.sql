CREATE TABLE public.cliente (
	id BIGSERIAL NOT NULL,
	cpf VARCHAR(11) NOT NULL,
	nome_completo VARCHAR(50) NOT NULL,
	email VARCHAR(50) NOT NULL,
	senha VARCHAR(20) NOT NULL,
	telefone VARCHAR(14) NOT NULL,
	logradouro VARCHAR(10) NOT NULL,
	endereco VARCHAR(150) NOT NULL,
	numero VARCHAR(10) NOT NULL,
	data_nascimento DATE NOT NULL,
	PRIMARY KEY (id),
	UNIQUE(cpf),
	UNIQUE(email),
	UNIQUE(telefone)
);

ALTER TABLE IF EXISTS public.cliente
OWNER TO postgres;

CREATE TABLE public.funcionario (
	id  BIGSERIAL NOT NULL,
	nome VARCHAR(50) NOT NULL,
	cpf VARCHAR(11) NOT NULL,
	salario NUMERIC NOT NULL,
	PRIMARY KEY (id),
	UNIQUE(cpf)
);

ALTER TABLE IF EXISTS public.funcionario
OWNER TO postgres;

CREATE TABLE public.produto (
	id BIGSERIAL NOT NULL,
	nome VARCHAR(50) NOT NULL,
	descricao text NOT NULL,
	data_fabricao DATE NOT NULL,
	quant_estoque INTEGER NOT NULL,
	valor_unidade INTEGER NOT NULL,
	data_cadastro TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	id_funcionario INTEGER NOT NULL,
	PRIMARY KEY (id),
	CONSTRAINT fk_id_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES public.funcionario (id) MATCH FULL
            ON UPDATE NO ACTION
            ON DELETE NO ACTION,
	UNIQUE(nome)
);

ALTER TABLE IF EXISTS public.produto
OWNER TO postgres;

CREATE TABLE public.compra (
	id BIGSERIAL NOT NULL,
	data_compra TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	id_produto INTEGER NOT NULL,
	id_cliente INTEGER NOT NULL,
	unidades_compradas INTEGER NOT NULL,
	PRIMARY KEY (id),
	CONSTRAINT fk_id_cliente FOREIGN KEY (id_cliente)
		REFERENCES public.cliente (id) MATCH FULL
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
	CONSTRAINT fk_id_produto FOREIGN KEY (id_produto)
		REFERENCES public.produto (id) MATCH FULL
			ON UPDATE NO ACTION
			ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS public.compra
OWNER TO postgres;

CREATE TABLE public.categoria (
	id BIGSERIAL NOT NULL,
	id_produto INTEGER NOT NULL,
	nome VARCHAR(50) NOT NULL,
	PRIMARY KEY (id),
	CONSTRAINT fk_id_produto FOREIGN KEY (id_produto)
		REFERENCES public.produto (id) MATCH FULL
			ON UPDATE NO ACTION
			ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS public.categoria
OWNER TO postgres;

--INSERTS

INSERT INTO public.cliente (cpf, nome_completo, email, senha, telefone, logradouro, endereco, numero, data_nascimento) VALUES
	('12345678911', 'João Victor M', 'Testejoao@gmail.com', '1234567879789', '+552299999', 'Rua', 'Presidente alguma coisa', '50', '05/05/1500'),
	('12355559112', 'Luciando', 'Testeluciando@gmail.com', '12345687978979', '+5521456486', 'Rua', 'Presidente de algum lugar', '5', '05/05/1500'),
	('12356459712', 'Brenda', 'TesteBrenda@gmail.com', '123456798798789', '+5521456745', 'Rua', 'Presidente CPM', '155', '05/05/1500'),
	('12357877812', 'TesteEmail', 'Testeluciandogmail.com', '123456789798798', '+5528789786', 'Rua', 'Presidente blablabla', '250', '05/05/1500'),
	('12357877778', 'TesteEmail', 'Testedluciando@gmail.com', '1234', '+552879786', 'Rua', 'Presidente blablabla', '250', '05/05/1500');

INSERT INTO public.funcionario (nome, cpf, salario) VALUES
	('ADMIN', '12345678551', 1500),
	('ADMIN2', '12578781234', 2500),
	('GERENTE', '57987231219', 10000);

INSERT INTO public.produto (nome, descricao, data_fabricao, quant_estoque,valor_unidade, id_funcionario) VALUES
	('Cadeira gamer', 'Confortável durante longas sessões', '05/05/1500', 50, 150, 1),
	('Mesa', 'Mesa confortável e duravel', '05/05/1500', '2', 1500, 3),
	('Fita', 'Super fita cola tudo', '05/05/1500', '90', 5, 2);

INSERT INTO public.categoria (id_produto, nome) VALUES
	(1, 'Periferico'),
	(1, 'Gamer'),
	(2, 'Escritorio'),
	(2, 'Madeira'),
	(3, 'Adesivo');

INSERT INTO public.compra (id_produto, id_cliente, unidades_compradas) VALUES
	(1, 1, 36),
	(2, 1, 150),
	(3, 2, 4),
	(3, 3, 35);


--CONSULTAS
--Uma consulta mostrando todos os produtos cadastrados, com o nome da categoria e o nome do funcionário que o cadastrou
SELECT c.nome AS categoria, p.nome AS Produto, f.nome AS Funcionario_cadastrou
FROM public.categoria c
	INNER JOIN public.produto p
		ON c.id_produto = p.id
	INNER JOIN public.funcionario f
		ON p.id_funcionario = f.id


--Uma consulta mostrando todos os pedidos feitos (sem os itensdo pedido), com o nome e telefone do cliente;
SELECT c.id AS id_venda, c2.nome_completo AS nome_cliente, c2.telefone AS telefone_cliente
FROM public.compra c
	INNER JOIN public.cliente c2
		ON c.id_cliente = c2.id
	
--Uma consulta mostrando todos os pedidos feitos, com seus itens, mostrando: número do pedido, nome do cliente, data do
--pedido, nome do produto comprado e a quantidade comprada de cada produto;
SELECT c.id AS id_venda, c2.nome_completo AS nome_cliente, p.nome AS nome_produto, c.data_compra, c.unidades_compradas
FROM public.compra c
	INNER JOIN public.cliente c2
		ON c.id_cliente = c2.id
	INNER JOIN public.produto p
		ON c.id_cliente = p.id

--Uma consulta mostrando a quantidade de pedidos por cliente, com resultado ordenado por nome do cliente, de modo crescente.
SELECT count(c2.id) AS Quantidade_de_compras, c2.nome_completo
FROM public.compra c
	INNER JOIN public.cliente c2
	ON c.id_cliente = c2.id
GROUP BY c2.nome_completo
ORDER BY Quantidade_de_compras ASC


--Um SQL que mude o salário de todos os funcionários: eles passarão a ganhar R$ 500,00 a mais;
UPDATE funcionario 
SET  salario = salario + 500;

--Um SQL que altere o email e o telefone de um cliente qualquer cadastrado.
UPDATE cliente
SET email = 'email@mail.com', telefone = '+55986866868'
WHERE id = 1;

--SQL de exclusão, dos clientes que foram cadastrados sem o caractere “@” no email ou que possuem uma senha com menos de 8 caracteres.
DELETE FROM public.cliente 
	WHERE email not like '%@%' 
	or CHAR_LENGTH(senha) < 8