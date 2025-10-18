-- =====================================================
-- EXEMPLOS DE INSERÇÃO DE CLIENTES PF E PJ
-- Usando transações para garantir atomicidade
-- =====================================================

-- =====================================================
-- EXEMPLO 1: CLIENTE PESSOA FÍSICA (João Silva)
-- =====================================================

-- Inserção em comando único usando transação
START TRANSACTION;

-- Inserir na tabela superclasse e capturar o ID
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone, cli_Ativo)
VALUES ('PF', 'Rua das Flores, 123, Centro, São Paulo, SP, 01234-567', 'joao.silva@email.com', '11987654321', TRUE);

-- Inserir na tabela especializada usando LAST_INSERT_ID()
INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
VALUES (LAST_INSERT_ID(), 'João Silva', '12345678901', '1990-05-15');

COMMIT;

-- =====================================================
-- EXEMPLO 2: CLIENTE PESSOA JURÍDICA (Empresa XYZ Ltda)
-- =====================================================

-- Inserção em comando único usando transação
START TRANSACTION;

-- Inserir na tabela superclasse e capturar o ID
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone, cli_Ativo)
VALUES ('PJ', 'Av. Paulista, 500, Bela Vista, São Paulo, SP, 01310-000', 'contato@empresaxyz.com.br', '1133445566', TRUE);

-- Inserir na tabela especializada usando LAST_INSERT_ID()
INSERT INTO clientes_pj (idCliente, cli_RazaoSocial, cli_CNPJ, cli_InscricaoEstadual, cli_NomeFantasia)
VALUES (LAST_INSERT_ID(), 'Empresa XYZ Ltda', '12345678000190', '123456789012', 'XYZ Store');

COMMIT;

-- =====================================================
-- EXEMPLO 3: INSERÇÃO COM VARIÁVEL (Mais Legível)
-- =====================================================

-- Cliente PF: Maria Santos
START TRANSACTION;

INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PF', 'Rua Augusta, 789, Consolação, São Paulo, SP, 01305-100', 'maria.santos@email.com', '11998877665');

SET @id_cliente = LAST_INSERT_ID();

INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
VALUES (@id_cliente, 'Maria Santos', '98765432109', '1985-08-20');

COMMIT;


-- Cliente PJ: Tech Solutions SA
START TRANSACTION;

INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PJ', 'Rua Vergueiro, 1000, Paraíso, São Paulo, SP, 04101-000', 'contato@techsolutions.com.br', '1144556677');

SET @id_cliente = LAST_INSERT_ID();

INSERT INTO clientes_pj (idCliente, cli_RazaoSocial, cli_CNPJ, cli_InscricaoEstadual, cli_NomeFantasia)
VALUES (@id_cliente, 'Tech Solutions SA', '98765432000111', '987654321098', 'Tech Solutions');

COMMIT;

-- =====================================================
-- EXEMPLO 4: PROCEDURE PARA INSERÇÃO PF (Recomendado)
-- =====================================================

DELIMITER //

CREATE PROCEDURE sp_inserir_cliente_pf(
    IN p_nome VARCHAR(255),
    IN p_cpf CHAR(11),
    IN p_data_nascimento DATE,
    IN p_email VARCHAR(100),
    IN p_telefone VARCHAR(11),
    IN p_endereco VARCHAR(255),
    OUT p_id_cliente INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Inserir na superclasse
    INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
    VALUES ('PF', p_endereco, p_email, p_telefone);
    
    SET p_id_cliente = LAST_INSERT_ID();
    
    -- Inserir na especialização
    INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
    VALUES (p_id_cliente, p_nome, p_cpf, p_data_nascimento);
    
    COMMIT;
END//

DELIMITER ;

-- Usar a procedure
CALL sp_inserir_cliente_pf(
    'Carlos Oliveira',
    '11122233344',
    '1992-03-10',
    'carlos.oliveira@email.com',
    '11955443322',
    'Rua dos Pinheiros, 456, Pinheiros, São Paulo, SP, 05422-000',
    @novo_id
);

SELECT @novo_id AS id_cliente_inserido;

-- =====================================================
-- EXEMPLO 5: PROCEDURE PARA INSERÇÃO PJ (Recomendado)
-- =====================================================

DELIMITER //

CREATE PROCEDURE sp_inserir_cliente_pj(
    IN p_razao_social VARCHAR(255),
    IN p_cnpj CHAR(14),
    IN p_inscricao_estadual VARCHAR(20),
    IN p_nome_fantasia VARCHAR(255),
    IN p_email VARCHAR(100),
    IN p_telefone VARCHAR(11),
    IN p_endereco VARCHAR(255),
    OUT p_id_cliente INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Inserir na superclasse
    INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
    VALUES ('PJ', p_endereco, p_email, p_telefone);
    
    SET p_id_cliente = LAST_INSERT_ID();
    
    -- Inserir na especialização
    INSERT INTO clientes_pj (idCliente, cli_RazaoSocial, cli_CNPJ, cli_InscricaoEstadual, cli_NomeFantasia)
    VALUES (p_id_cliente, p_razao_social, p_cnpj, p_inscricao_estadual, p_nome_fantasia);
    
    COMMIT;
END//

DELIMITER ;

-- Usar a procedure
CALL sp_inserir_cliente_pj(
    'Comércio ABC Ltda',
    '55566677000188',
    '555666777888',
    'ABC Comércio',
    'contato@comercioabc.com.br',
    '1122334455',
    'Av. Brasil, 2000, Jardins, São Paulo, SP, 01431-000',
    @novo_id
);

SELECT @novo_id AS id_cliente_inserido;

-- =====================================================
-- EXEMPLO 6: INSERÇÃO EM LOTE (BATCH INSERT)
-- =====================================================

-- Múltiplos clientes PF
START TRANSACTION;

-- Cliente PF 1
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PF', 'Rua A, 100, Bairro X, São Paulo, SP', 'cliente1@email.com', '11911111111');
INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
VALUES (LAST_INSERT_ID(), 'Ana Costa', '11111111111', '1988-01-15');

-- Cliente PF 2
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PF', 'Rua B, 200, Bairro Y, São Paulo, SP', 'cliente2@email.com', '11922222222');
INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
VALUES (LAST_INSERT_ID(), 'Bruno Lima', '22222222222', '1991-07-22');

-- Cliente PF 3
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PF', 'Rua C, 300, Bairro Z, São Paulo, SP', 'cliente3@email.com', '11933333333');
INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
VALUES (LAST_INSERT_ID(), 'Carla Souza', '33333333333', '1995-11-30');

COMMIT;

-- Múltiplos clientes PJ
START TRANSACTION;

-- Cliente PJ 1
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PJ', 'Av. X, 1000, Centro, São Paulo, SP', 'empresa1@email.com', '1144444444');
INSERT INTO clientes_pj (idCliente, cli_RazaoSocial, cli_CNPJ, cli_NomeFantasia)
VALUES (LAST_INSERT_ID(), 'Empresa Alpha Ltda', '11111111000111', 'Alpha Store');

-- Cliente PJ 2
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PJ', 'Av. Y, 2000, Zona Sul, São Paulo, SP', 'empresa2@email.com', '1155555555');
INSERT INTO clientes_pj (idCliente, cli_RazaoSocial, cli_CNPJ, cli_NomeFantasia)
VALUES (LAST_INSERT_ID(), 'Empresa Beta SA', '22222222000122', 'Beta Tech');

-- Cliente PJ 3
INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PJ', 'Av. Z, 3000, Zona Norte, São Paulo, SP', 'empresa3@email.com', '1166666666');
INSERT INTO clientes_pj (idCliente, cli_RazaoSocial, cli_CNPJ, cli_NomeFantasia)
VALUES (LAST_INSERT_ID(), 'Empresa Gamma Ltda', '33333333000133', 'Gamma Solutions');

COMMIT;

-- =====================================================
-- EXEMPLO 7: VALIDAÇÃO E CONSULTA APÓS INSERÇÃO
-- =====================================================

-- Inserir e validar imediatamente
START TRANSACTION;

INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PF', 'Rua Teste, 999, Teste, São Paulo, SP', 'teste@email.com', '11999999999');

SET @id_teste = LAST_INSERT_ID();

INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
VALUES (@id_teste, 'Cliente Teste', '99999999999', '2000-12-31');

-- Validar a inserção
SELECT 
    c.idCliente,
    c.cli_TipoCliente,
    pf.cli_Nome,
    pf.cli_CPF,
    c.cli_Email,
    c.cli_DataCadastro
FROM clientes c
JOIN clientes_pf pf ON c.idCliente = pf.idCliente
WHERE c.idCliente = @id_teste;

COMMIT;

-- =====================================================
-- EXEMPLO 8: TRATAMENTO DE ERROS
-- =====================================================

-- Tentativa de inserir PJ em tabela PF (deve falhar)
START TRANSACTION;

INSERT INTO clientes (cli_TipoCliente, cli_Endereco, cli_Email, cli_ContatoTelefone)
VALUES ('PJ', 'Endereço Erro', 'erro@email.com', '11888888888');

-- Isso causará ERRO devido ao trigger de validação
INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento)
VALUES (LAST_INSERT_ID(), 'Erro Teste', '88888888888', '1990-01-01');
-- ERRO: Cliente não é do tipo Pessoa Física

ROLLBACK;
