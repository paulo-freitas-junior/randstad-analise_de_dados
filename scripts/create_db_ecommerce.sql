-- =====================================================
-- SCHEMA DE BANCO DE DADOS - E-COMMERCE REFINADO
-- Sistema: E-commerce com especialização de clientes
-- SGBD: MySQL 8.0+
-- =====================================================

-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS ecommerce_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ecommerce_db;

-- =====================================================
-- TABELA: clientes (Superclasse)
-- =====================================================
CREATE TABLE clientes (
    idCliente INT AUTO_INCREMENT,
    cli_TipoCliente ENUM('PF', 'PJ') NOT NULL COMMENT 'Tipo de cliente: Pessoa Física ou Jurídica',
    cli_Endereco VARCHAR(255),
    cli_Email VARCHAR(100),
    cli_ContatoTelefone VARCHAR(11),
    cli_DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    cli_Ativo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (idCliente),
    INDEX idx_tipo_cliente (cli_TipoCliente),
    INDEX idx_email (cli_Email),
    INDEX idx_data_cadastro (cli_DataCadastro)
) ENGINE=InnoDB COMMENT='Tabela principal de clientes';

-- =====================================================
-- TABELA: clientes_pf (Pessoa Física)
-- =====================================================
CREATE TABLE clientes_pf (
    idCliente INT,
    cli_Nome VARCHAR(255) NOT NULL,
    cli_CPF CHAR(11) NOT NULL,
    cli_DataNascimento DATE,
    PRIMARY KEY (idCliente),
    UNIQUE KEY uk_cpf (cli_CPF),
    CONSTRAINT fk_clientepf_cliente 
        FOREIGN KEY (idCliente) 
        REFERENCES clientes(idCliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_cpf_valido 
        CHECK (cli_CPF REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB COMMENT='Especialização: Clientes Pessoa Física';

-- =====================================================
-- TABELA: clientes_pj (Pessoa Jurídica)
-- =====================================================
CREATE TABLE clientes_pj (
    idCliente INT,
    cli_RazaoSocial VARCHAR(255) NOT NULL,
    cli_CNPJ CHAR(14) NOT NULL,
    cli_InscricaoEstadual VARCHAR(20),
    cli_NomeFantasia VARCHAR(255),
    PRIMARY KEY (idCliente),
    UNIQUE KEY uk_cnpj (cli_CNPJ),
    CONSTRAINT fk_clientepj_cliente 
        FOREIGN KEY (idCliente) 
        REFERENCES clientes(idCliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_cnpj_valido 
        CHECK (cli_CNPJ REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB COMMENT='Especialização: Clientes Pessoa Jurídica';

-- =====================================================
-- TABELA: formas_pagamento
-- =====================================================
CREATE TABLE formas_pagamento (
    idFormaPagamento INT AUTO_INCREMENT,
    idCliente INT NOT NULL,
    fp_Tipo ENUM('Cartao_Credito', 'Cartao_Debito', 'Boleto', 'PIX', 'Transferencia') NOT NULL,
    fp_Principal BOOLEAN DEFAULT FALSE COMMENT 'Indica se é a forma de pagamento principal',
    fp_Ativo BOOLEAN DEFAULT TRUE,
    fp_DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idFormaPagamento),
    CONSTRAINT fk_formapag_cliente 
        FOREIGN KEY (idCliente) 
        REFERENCES clientes(idCliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_cliente_tipo (idCliente, fp_Tipo),
    INDEX idx_principal (idCliente, fp_Principal)
) ENGINE=InnoDB COMMENT='Formas de pagamento cadastradas por cliente';

-- =====================================================
-- TABELA: cartoes
-- =====================================================
CREATE TABLE cartoes (
    idCartao INT AUTO_INCREMENT,
    idFormaPagamento INT NOT NULL,
    car_NomeTitular VARCHAR(255) NOT NULL,
    car_Bandeira ENUM('Visa', 'Mastercard', 'Elo', 'Amex', 'Hipercard', 'Diners', 'Discover') NOT NULL,
    car_NumeroCartao VARCHAR(16) NOT NULL COMMENT 'Em produção deve ser criptografado',
    car_Validade CHAR(5) NOT NULL COMMENT 'Formato MM/AA',
    car_CVV CHAR(3) NOT NULL COMMENT 'Em produção deve ser criptografado',
    PRIMARY KEY (idCartao),
    UNIQUE KEY uk_forma_pagamento (idFormaPagamento),
    CONSTRAINT fk_cartao_formapag 
        FOREIGN KEY (idFormaPagamento) 
        REFERENCES formas_pagamento(idFormaPagamento)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_bandeira (car_Bandeira)
) ENGINE=InnoDB COMMENT='Dados específicos de cartões de crédito/débito';

-- =====================================================
-- TABELA: pedidos
-- =====================================================
CREATE TABLE pedidos (
    idPedido INT AUTO_INCREMENT,
    idCliente INT NOT NULL,
    ped_Status ENUM('Pendente', 'Confirmado', 'Processando', 'Enviado', 'Entregue', 'Cancelado') DEFAULT 'Pendente',
    ped_Descricao VARCHAR(255),
    ped_ValorFrete DECIMAL(10,2) DEFAULT 0.00,
    ped_ValorTotal DECIMAL(10,2) NOT NULL,
    ped_DataPedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    ped_DataAtualizacao DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (idPedido),
    CONSTRAINT fk_pedido_cliente 
        FOREIGN KEY (idCliente) 
        REFERENCES clientes(idCliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    INDEX idx_cliente_data (idCliente, ped_DataPedido),
    INDEX idx_status (ped_Status),
    INDEX idx_data_pedido (ped_DataPedido),
    CONSTRAINT chk_valor_total_positivo 
        CHECK (ped_ValorTotal >= 0)
) ENGINE=InnoDB COMMENT='Pedidos realizados pelos clientes';

-- =====================================================
-- TABELA: pedidos_pagamentos
-- =====================================================
CREATE TABLE pedidos_pagamentos (
    idPedidoPagamento INT AUTO_INCREMENT,
    idPedido INT NOT NULL,
    idFormaPagamento INT NOT NULL,
    pag_Valor DECIMAL(10,2) NOT NULL,
    pag_Status ENUM('Pendente', 'Processando', 'Aprovado', 'Recusado', 'Estornado', 'Cancelado') DEFAULT 'Pendente',
    pag_DataPagamento DATETIME DEFAULT CURRENT_TIMESTAMP,
    pag_DataAtualizacao DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    pag_NumeroTransacao VARCHAR(100),
    pag_MensagemRetorno TEXT,
    PRIMARY KEY (idPedidoPagamento),
    CONSTRAINT fk_pagpedido_pedido 
        FOREIGN KEY (idPedido) 
        REFERENCES pedidos(idPedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pagpedido_formapag 
        FOREIGN KEY (idFormaPagamento) 
        REFERENCES formas_pagamento(idFormaPagamento)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    INDEX idx_pedido (idPedido),
    INDEX idx_status_pagamento (pag_Status),
    INDEX idx_transacao (pag_NumeroTransacao),
    CONSTRAINT chk_valor_pagamento_positivo 
        CHECK (pag_Valor > 0)
) ENGINE=InnoDB COMMENT='Relacionamento entre pedidos e formas de pagamento';

-- =====================================================
-- TABELA: entregas
-- =====================================================
CREATE TABLE entregas (
    idEntrega INT AUTO_INCREMENT,
    idPedido INT NOT NULL,
    ent_Status ENUM(
        'Aguardando',
        'Preparando',
        'Despachado',
        'Em_Transito',
        'Saiu_Entrega',
        'Entregue',
        'Tentativa_Falha',
        'Devolvido'
    ) DEFAULT 'Aguardando',
    ent_CodigoRastreio VARCHAR(50),
    ent_Transportadora VARCHAR(100),
    ent_EnderecoEntrega VARCHAR(255) NOT NULL,
    ent_DataEnvio DATETIME,
    ent_DataPrevisao DATE,
    ent_DataEntrega DATETIME,
    ent_Observacoes TEXT,
    ent_NomeRecebedor VARCHAR(255),
    ent_DocumentoRecebedor VARCHAR(20),
    PRIMARY KEY (idEntrega),
    UNIQUE KEY uk_pedido (idPedido),
    UNIQUE KEY uk_codigo_rastreio (ent_CodigoRastreio),
    CONSTRAINT fk_entrega_pedido 
        FOREIGN KEY (idPedido) 
        REFERENCES pedidos(idPedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_status_entrega (ent_Status),
    INDEX idx_codigo_rastreio (ent_CodigoRastreio),
    INDEX idx_data_previsao (ent_DataPrevisao)
) ENGINE=InnoDB COMMENT='Informações de entrega dos pedidos';

-- =====================================================
-- TABELA: historico_rastreamento
-- =====================================================
CREATE TABLE historico_rastreamento (
    idHistorico INT AUTO_INCREMENT,
    idEntrega INT NOT NULL,
    hist_Status VARCHAR(100) NOT NULL,
    hist_Localizacao VARCHAR(255),
    hist_Descricao TEXT,
    hist_DataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idHistorico),
    CONSTRAINT fk_historico_entrega 
        FOREIGN KEY (idEntrega) 
        REFERENCES entregas(idEntrega)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_entrega_data (idEntrega, hist_DataHora)
) ENGINE=InnoDB COMMENT='Histórico de movimentação das entregas';

-- =====================================================
-- TABELA: produtos
-- =====================================================
CREATE TABLE produtos (
    idProduto INT AUTO_INCREMENT,
    prod_Nome VARCHAR(255) NOT NULL,
    prod_Categoria ENUM(
        'Eletronicos',
        'Vestuario',
        'Alimentos',
        'Livros',
        'Esportes',
        'Casa',
        'Beleza',
        'Brinquedos',
        'Outros'
    ),
    prod_Descricao TEXT,
    prod_Preco DECIMAL(10,2) NOT NULL,
    prod_Estoque INT DEFAULT 0,
    prod_Ativo BOOLEAN DEFAULT TRUE,
    prod_DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idProduto),
    INDEX idx_categoria (prod_Categoria),
    INDEX idx_nome (prod_Nome),
    INDEX idx_preco (prod_Preco),
    INDEX idx_ativo (prod_Ativo),
    CONSTRAINT chk_preco_positivo 
        CHECK (prod_Preco >= 0),
    CONSTRAINT chk_estoque_nao_negativo 
        CHECK (prod_Estoque >= 0)
) ENGINE=InnoDB COMMENT='Catálogo de produtos';

-- =====================================================
-- TABELA: itens_pedido
-- =====================================================
CREATE TABLE itens_pedido (
    idItemPedido INT AUTO_INCREMENT,
    idPedido INT NOT NULL,
    idProduto INT NOT NULL,
    item_Quantidade INT NOT NULL,
    item_PrecoUnitario DECIMAL(10,2) NOT NULL,
    item_Desconto DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (idItemPedido),
    CONSTRAINT fk_item_pedido 
        FOREIGN KEY (idPedido) 
        REFERENCES pedidos(idPedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_item_produto 
        FOREIGN KEY (idProduto) 
        REFERENCES produtos(idProduto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    INDEX idx_pedido (idPedido),
    INDEX idx_produto (idProduto),
    CONSTRAINT chk_quantidade_positiva 
        CHECK (item_Quantidade > 0),
    CONSTRAINT chk_preco_unitario_positivo 
        CHECK (item_PrecoUnitario >= 0),
    CONSTRAINT chk_desconto_valido 
        CHECK (item_Desconto >= 0)
) ENGINE=InnoDB COMMENT='Itens que compõem cada pedido';

-- =====================================================
-- TABELA: fornecedores
-- =====================================================
CREATE TABLE fornecedores (
    idFornecedor INT AUTO_INCREMENT,
    for_RazaoSocial VARCHAR(255) NOT NULL,
    for_CNPJ CHAR(14),
    for_ContatoTelefone VARCHAR(11),
    for_Email VARCHAR(100),
    for_Endereco VARCHAR(255),
    for_Ativo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (idFornecedor),
    UNIQUE KEY uk_cnpj_fornecedor (for_CNPJ),
    INDEX idx_razao_social (for_RazaoSocial)
) ENGINE=InnoDB COMMENT='Fornecedores de produtos';

-- =====================================================
-- TABELA: produtos_fornecedores
-- =====================================================
CREATE TABLE produtos_fornecedores (
    idProdutoFornecedor INT AUTO_INCREMENT,
    idProduto INT NOT NULL,
    idFornecedor INT NOT NULL,
    prodforn_Quantidade INT DEFAULT 0,
    PRIMARY KEY (idProdutoFornecedor),
    CONSTRAINT fk_prodforn_produto 
        FOREIGN KEY (idProduto) 
        REFERENCES produtos(idProduto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_prodforn_fornecedor 
        FOREIGN KEY (idFornecedor) 
        REFERENCES fornecedores(idFornecedor)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE KEY uk_produto_fornecedor (idProduto, idFornecedor),
    INDEX idx_fornecedor (idFornecedor)
) ENGINE=InnoDB COMMENT='Relacionamento entre produtos e fornecedores';

-- =====================================================
-- TABELA: vendedores
-- =====================================================
CREATE TABLE vendedores (
    idVendedor INT AUTO_INCREMENT,
    ven_RazaoSocial VARCHAR(255) NOT NULL,
    ven_CNPJ CHAR(14),
    ven_ContatoTelefone VARCHAR(11),
    ven_Email VARCHAR(100),
    ven_Localidade VARCHAR(255),
    ven_Ativo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (idVendedor),
    UNIQUE KEY uk_cnpj_vendedor (ven_CNPJ),
    INDEX idx_razao_social_vendedor (ven_RazaoSocial)
) ENGINE=InnoDB COMMENT='Vendedores terceiros (marketplace)';

-- =====================================================
-- TABELA: produtos_vendedores
-- =====================================================
CREATE TABLE produtos_vendedores (
    idProdutoVendedor INT AUTO_INCREMENT,
    idProduto INT NOT NULL,
    idVendedor INT NOT NULL,
    prodvend_Quantidade INT DEFAULT 0,
    PRIMARY KEY (idProdutoVendedor),
    CONSTRAINT fk_prodvend_produto 
        FOREIGN KEY (idProduto) 
        REFERENCES produtos(idProduto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_prodvend_vendedor 
        FOREIGN KEY (idVendedor) 
        REFERENCES vendedores(idVendedor)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE KEY uk_produto_vendedor (idProduto, idVendedor),
    INDEX idx_vendedor (idVendedor)
) ENGINE=InnoDB COMMENT='Relacionamento entre produtos e vendedores';

-- =====================================================
-- TABELA: estoque_produtos
-- =====================================================
CREATE TABLE estoque_produtos (
    idEstoque INT AUTO_INCREMENT,
    idProduto INT NOT NULL,
    est_Localidade VARCHAR(255) NOT NULL,
    est_Quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (idEstoque),
    CONSTRAINT fk_estoque_produto 
        FOREIGN KEY (idProduto) 
        REFERENCES produtos(idProduto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_produto_localidade (idProduto, est_Localidade),
    CONSTRAINT chk_quantidade_estoque 
        CHECK (est_Quantidade >= 0)
) ENGINE=InnoDB COMMENT='Controle de estoque por localidade';

-- =====================================================
-- TABELA: estoque_localidades
-- =====================================================
CREATE TABLE estoque_localidades (
    idLocalidade INT AUTO_INCREMENT,
    idProduto INT NOT NULL,
    idEstoque INT NOT NULL,
    est_Localidade VARCHAR(255) NOT NULL,
    PRIMARY KEY (idLocalidade),
    CONSTRAINT fk_locest_produto 
        FOREIGN KEY (idProduto) 
        REFERENCES produtos(idProduto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_locest_estoque 
        FOREIGN KEY (idEstoque) 
        REFERENCES estoque_produtos(idEstoque)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE KEY uk_produto_estoque_localidade (idProduto, idEstoque)
) ENGINE=InnoDB COMMENT='Localidades de estoque';

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger para garantir que cliente só pode ser PF OU PJ
DELIMITER //

CREATE TRIGGER trg_validar_especializacao_cliente_insert
BEFORE INSERT ON clientes_pf
FOR EACH ROW
BEGIN
    DECLARE tipo_cliente VARCHAR(2);
    
    SELECT cli_TipoCliente INTO tipo_cliente 
    FROM clientes 
    WHERE idCliente = NEW.idCliente;
    
    IF tipo_cliente != 'PF' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente não é do tipo Pessoa Física';
    END IF;
END//

CREATE TRIGGER trg_validar_especializacao_cliente_pj_insert
BEFORE INSERT ON clientes_pj
FOR EACH ROW
BEGIN
    DECLARE tipo_cliente VARCHAR(2);
    
    SELECT cli_TipoCliente INTO tipo_cliente 
    FROM clientes 
    WHERE idCliente = NEW.idCliente;
    
    IF tipo_cliente != 'PJ' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente não é do tipo Pessoa Jurídica';
    END IF;
END//

-- Trigger para atualizar estoque ao adicionar item ao pedido
CREATE TRIGGER trg_atualizar_estoque_insert
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE produtos 
    SET prod_Estoque = prod_Estoque - NEW.item_Quantidade
    WHERE idProduto = NEW.idProduto;
END//

-- Trigger para restaurar estoque ao cancelar pedido
CREATE TRIGGER trg_restaurar_estoque_delete
AFTER DELETE ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE produtos 
    SET prod_Estoque = prod_Estoque + OLD.item_Quantidade
    WHERE idProduto = OLD.idProduto;
END//

-- Trigger para criar registro de rastreamento ao atualizar status
CREATE TRIGGER trg_criar_historico_rastreamento
AFTER UPDATE ON entregas
FOR EACH ROW
BEGIN
    IF OLD.ent_Status != NEW.ent_Status THEN
        INSERT INTO historico_rastreamento 
            (idEntrega, hist_Status, hist_Descricao)
        VALUES 
            (NEW.idEntrega, NEW.ent_Status, CONCAT('Status alterado de ', OLD.ent_Status, ' para ', NEW.ent_Status));
    END IF;
END//

DELIMITER ;

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View: Clientes completos (PF e PJ unificados)
CREATE VIEW vw_clientes_completos AS
SELECT 
    c.idCliente,
    c.cli_TipoCliente,
    COALESCE(pf.cli_Nome, pj.cli_RazaoSocial) AS nome_completo,
    COALESCE(pf.cli_CPF, pj.cli_CNPJ) AS documento,
    c.cli_Email,
    c.cli_ContatoTelefone,
    c.cli_Endereco,
    c.cli_DataCadastro,
    c.cli_Ativo
FROM clientes c
LEFT JOIN clientes_pf pf ON c.idCliente = pf.idCliente
LEFT JOIN clientes_pj pj ON c.idCliente = pj.idCliente;

-- View: Pedidos com informações de cliente e pagamento
CREATE VIEW vw_pedidos_completos AS
SELECT 
    p.idPedido,
    p.idCliente,
    vc.nome_completo AS cliente,
    vc.cli_TipoCliente,
    p.ped_Status,
    p.ped_ValorTotal,
    p.ped_ValorFrete,
    p.ped_DataPedido,
    COUNT(DISTINCT ip.idItemPedido) AS total_itens,
    SUM(ip.item_Quantidade) AS quantidade_produtos,
    GROUP_CONCAT(DISTINCT pp.pag_Status) AS status_pagamentos
FROM pedidos p
INNER JOIN vw_clientes_completos vc ON p.idCliente = vc.idCliente
LEFT JOIN itens_pedido ip ON p.idPedido = ip.idPedido
LEFT JOIN pedidos_pagamentos pp ON p.idPedido = pp.idPedido
GROUP BY p.idPedido, p.idCliente, vc.nome_completo, vc.cli_TipoCliente, 
         p.ped_Status, p.ped_ValorTotal, p.ped_ValorFrete, p.ped_DataPedido;

-- View: Entregas com rastreamento
CREATE VIEW vw_entregas_rastreamento AS
SELECT 
    e.idEntrega,
    e.idPedido,
    p.idCliente,
    e.ent_Status,
    e.ent_CodigoRastreio,
    e.ent_Transportadora,
    e.ent_DataEnvio,
    e.ent_DataPrevisao,
    e.ent_DataEntrega,
    (SELECT hist_Status 
     FROM historico_rastreamento 
     WHERE idEntrega = e.idEntrega 
     ORDER BY hist_DataHora DESC 
     LIMIT 1) AS ultimo_status_rastreamento,
    (SELECT hist_DataHora 
     FROM historico_rastreamento 
     WHERE idEntrega = e.idEntrega 
     ORDER BY hist_DataHora DESC 
     LIMIT 1) AS data_ultima_atualizacao
FROM entregas e
INNER JOIN pedidos p ON e.idPedido = p.idPedido;

-- =====================================================
-- PROCEDURES ÚTEIS
-- =====================================================

DELIMITER //

-- Procedure para criar pedido completo
CREATE PROCEDURE sp_criar_pedido(
    IN p_idCliente INT,
    IN p_valorTotal DECIMAL(10,2),
    IN p_valorFrete DECIMAL(10,2),
    IN p_descricao VARCHAR(255),
    OUT p_idPedido INT
)
BEGIN
    INSERT INTO pedidos (idCliente, ped_ValorTotal, ped_ValorFrete, ped_Descricao)
    VALUES (p_idCliente, p_valorTotal, p_valorFrete, p_descricao);
    
    SET p_idPedido = LAST_INSERT_ID();
END//

-- Procedure para atualizar status do pedido e entrega
CREATE PROCEDURE sp_atualizar_status_pedido(
    IN p_idPedido INT,
    IN p_novoStatus VARCHAR(50)
)
BEGIN
    UPDATE pedidos 
    SET ped_Status = p_novoStatus 
    WHERE idPedido = p_idPedido;
    
    IF p_novoStatus = 'Enviado' THEN
        UPDATE entregas 
        SET ent_Status = 'Em_Transito',
            ent_DataEnvio = NOW()
        WHERE idPedido = p_idPedido;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================

-- Inserir clientes PF
INSERT INTO clientes (cli_TipoCliente, cli_Email, cli_ContatoTelefone, cli_Endereco) 
VALUES ('PF', 'joao.silva@email.com', '11987654321', 'Rua A, 123');

INSERT INTO clientes_pf (idCliente, cli_Nome, cli_CPF, cli_DataNascimento) 
VALUES (1, 'João Silva', '12345678901', '1990-05-15');

-- Inserir clientes PJ
INSERT INTO clientes (cli_TipoCliente, cli_Email, cli_ContatoTelefone, cli_Endereco) 
VALUES ('PJ', 'contato@empresa.com', '11912345678', 'Av. Principal, 500');

INSERT INTO clientes_pj (idCliente, cli_RazaoSocial, cli_CNPJ, cli_NomeFantasia) 
VALUES (2, 'Empresa XYZ Ltda', '12345678000190', 'XYZ Store');

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================