-- =====================================================
-- SISTEMA DE GERENCIAMENTO DE OFICINA MECÂNICA
-- Sistema: Oficina Mecânica
-- SGBD: MySQL 8.0+
-- =====================================================

CREATE DATABASE IF NOT EXISTS oficina_mecanica;
USE oficina_mecanica;

-- =====================================================
-- TABELA: CLIENTES
-- =====================================================
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(18) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco VARCHAR(200),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep VARCHAR(10),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_cpf_cnpj (cpf_cnpj),
    INDEX idx_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: VEÍCULOS
-- =====================================================
CREATE TABLE veiculos (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    placa VARCHAR(10) UNIQUE NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    ano_fabricacao YEAR,
    ano_modelo YEAR,
    cor VARCHAR(30),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    INDEX idx_placa (placa),
    INDEX idx_cliente (id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: MECÂNICOS
-- =====================================================
CREATE TABLE mecanicos (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep VARCHAR(10),
    telefone VARCHAR(20),
    especialidade VARCHAR(100),
    data_admissao DATE,
    salario DECIMAL(10, 2),
    status ENUM('Ativo', 'Inativo', 'Férias') DEFAULT 'Ativo',
    INDEX idx_codigo (codigo),
    INDEX idx_especialidade (especialidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: EQUIPES
-- =====================================================
CREATE TABLE equipes (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(100) NOT NULL,
    descricao TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: MECÂNICOS POR EQUIPE (Relacionamento N:N)
-- =====================================================
CREATE TABLE equipe_mecanicos (
    id_equipe INT,
    id_mecanico INT,
    data_entrada DATE NOT NULL,
    PRIMARY KEY (id_equipe, id_mecanico),
    FOREIGN KEY (id_equipe) REFERENCES equipes(id_equipe),
    FOREIGN KEY (id_mecanico) REFERENCES mecanicos(id_mecanico)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: CATÁLOGO DE SERVIÇOS
-- =====================================================
CREATE TABLE catalogo_servicos (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    codigo_servico VARCHAR(20) UNIQUE NOT NULL,
    descricao VARCHAR(200) NOT NULL,
    categoria VARCHAR(50),
    INDEX idx_codigo (codigo_servico)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: TABELA DE REFERÊNCIA DE MÃO-DE-OBRA
-- =====================================================
CREATE TABLE tabela_mao_obra (
    id_tabela INT AUTO_INCREMENT PRIMARY KEY,
    id_servico INT NOT NULL,
    valor_mao_obra DECIMAL(10, 2) NOT NULL,
    tempo_estimado_horas DECIMAL(5, 2),
    data_vigencia_inicio DATE NOT NULL,
    data_vigencia_fim DATE,
    FOREIGN KEY (id_servico) REFERENCES catalogo_servicos(id_servico),
    INDEX idx_servico_vigencia (id_servico, data_vigencia_inicio, data_vigencia_fim)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: CATÁLOGO DE PEÇAS
-- =====================================================
CREATE TABLE catalogo_pecas (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    codigo_peca VARCHAR(30) UNIQUE NOT NULL,
    descricao VARCHAR(200) NOT NULL,
    marca VARCHAR(50),
    valor_unitario DECIMAL(10, 2) NOT NULL,
    estoque_atual INT DEFAULT 0,
    estoque_minimo INT DEFAULT 0,
    INDEX idx_codigo (codigo_peca)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: ORDENS DE SERVIÇO
-- =====================================================
CREATE TABLE ordens_servico (
    numero_os INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_equipe INT NOT NULL,
    data_emissao DATE NOT NULL,
    data_conclusao_prevista DATE NOT NULL,
    data_conclusao_real DATE,
    valor_total DECIMAL(10, 2) DEFAULT 0.00,
    valor_mao_obra DECIMAL(10, 2) DEFAULT 0.00,
    valor_pecas DECIMAL(10, 2) DEFAULT 0.00,
    status ENUM('Aguardando Autorização', 'Autorizada', 'Em Execução', 'Concluída', 'Cancelada') DEFAULT 'Aguardando Autorização',
    observacoes TEXT,
    data_autorizacao DATETIME,
    FOREIGN KEY (id_veiculo) REFERENCES veiculos(id_veiculo),
    FOREIGN KEY (id_equipe) REFERENCES equipes(id_equipe),
    INDEX idx_veiculo (id_veiculo),
    INDEX idx_status (status),
    INDEX idx_data_emissao (data_emissao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: SERVIÇOS DA OS (Relacionamento N:N)
-- =====================================================
CREATE TABLE os_servicos (
    id_os_servico INT AUTO_INCREMENT PRIMARY KEY,
    numero_os INT NOT NULL,
    id_servico INT NOT NULL,
    valor_mao_obra DECIMAL(10, 2) NOT NULL,
    tempo_execucao_horas DECIMAL(5, 2),
    observacoes TEXT,
    FOREIGN KEY (numero_os) REFERENCES ordens_servico(numero_os),
    FOREIGN KEY (id_servico) REFERENCES catalogo_servicos(id_servico),
    INDEX idx_os (numero_os),
    INDEX idx_servico (id_servico)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: PEÇAS DA OS (Relacionamento N:N)
-- =====================================================
CREATE TABLE os_pecas (
    id_os_peca INT AUTO_INCREMENT PRIMARY KEY,
    numero_os INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT NOT NULL,
    valor_unitario DECIMAL(10, 2) NOT NULL,
    valor_total DECIMAL(10, 2) GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,
    FOREIGN KEY (numero_os) REFERENCES ordens_servico(numero_os),
    FOREIGN KEY (id_peca) REFERENCES catalogo_pecas(id_peca),
    INDEX idx_os (numero_os),
    INDEX idx_peca (id_peca)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA DE VALORES
-- =====================================================

DELIMITER $$

-- Trigger para atualizar valor total da OS após inserir serviço
CREATE TRIGGER trg_os_servicos_after_insert
AFTER INSERT ON os_servicos
FOR EACH ROW
BEGIN
    UPDATE ordens_servico
    SET valor_mao_obra = (
        SELECT COALESCE(SUM(valor_mao_obra), 0)
        FROM os_servicos
        WHERE numero_os = NEW.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = NEW.numero_os;
END$$

-- Trigger para atualizar valor total da OS após atualizar serviço
CREATE TRIGGER trg_os_servicos_after_update
AFTER UPDATE ON os_servicos
FOR EACH ROW
BEGIN
    UPDATE ordens_servico
    SET valor_mao_obra = (
        SELECT COALESCE(SUM(valor_mao_obra), 0)
        FROM os_servicos
        WHERE numero_os = NEW.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = NEW.numero_os;
END$$

-- Trigger para atualizar valor total da OS após deletar serviço
CREATE TRIGGER trg_os_servicos_after_delete
AFTER DELETE ON os_servicos
FOR EACH ROW
BEGIN
    UPDATE ordens_servico
    SET valor_mao_obra = (
        SELECT COALESCE(SUM(valor_mao_obra), 0)
        FROM os_servicos
        WHERE numero_os = OLD.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = OLD.numero_os;
END$$

-- Trigger para atualizar valor total da OS após inserir peça
CREATE TRIGGER trg_os_pecas_after_insert
AFTER INSERT ON os_pecas
FOR EACH ROW
BEGIN
    UPDATE ordens_servico
    SET valor_pecas = (
        SELECT COALESCE(SUM(valor_total), 0)
        FROM os_pecas
        WHERE numero_os = NEW.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = NEW.numero_os;
    
    -- Atualiza estoque
    UPDATE catalogo_pecas
    SET estoque_atual = estoque_atual - NEW.quantidade
    WHERE id_peca = NEW.id_peca;
END$$

-- Trigger para atualizar valor total da OS após atualizar peça
CREATE TRIGGER trg_os_pecas_after_update
AFTER UPDATE ON os_pecas
FOR EACH ROW
BEGIN
    UPDATE ordens_servico
    SET valor_pecas = (
        SELECT COALESCE(SUM(valor_total), 0)
        FROM os_pecas
        WHERE numero_os = NEW.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = NEW.numero_os;
    
    -- Ajusta estoque
    UPDATE catalogo_pecas
    SET estoque_atual = estoque_atual + OLD.quantidade - NEW.quantidade
    WHERE id_peca = NEW.id_peca;
END$$

-- Trigger para atualizar valor total da OS após deletar peça
CREATE TRIGGER trg_os_pecas_after_delete
AFTER DELETE ON os_pecas
FOR EACH ROW
BEGIN
    UPDATE ordens_servico
    SET valor_pecas = (
        SELECT COALESCE(SUM(valor_total), 0)
        FROM os_pecas
        WHERE numero_os = OLD.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = OLD.numero_os;
    
    -- Devolve ao estoque
    UPDATE catalogo_pecas
    SET estoque_atual = estoque_atual + OLD.quantidade
    WHERE id_peca = OLD.id_peca;
END$$

DELIMITER ;

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View para listar OS completas com informações do cliente e veículo
CREATE VIEW vw_ordens_servico_completas AS
SELECT 
    os.numero_os,
    os.data_emissao,
    os.data_conclusao_prevista,
    os.data_conclusao_real,
    os.status,
    os.valor_total,
    c.nome AS cliente_nome,
    c.telefone AS cliente_telefone,
    v.placa,
    v.marca,
    v.modelo,
    e.nome_equipe
FROM ordens_servico os
INNER JOIN veiculos v ON os.id_veiculo = v.id_veiculo
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN equipes e ON os.id_equipe = e.id_equipe;

-- View para listar peças com estoque baixo
CREATE VIEW vw_pecas_estoque_baixo AS
SELECT 
    codigo_peca,
    descricao,
    marca,
    estoque_atual,
    estoque_minimo,
    (estoque_minimo - estoque_atual) AS quantidade_repor
FROM catalogo_pecas
WHERE estoque_atual <= estoque_minimo;

-- =====================================================
-- DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================

-- Inserir clientes de exemplo
INSERT INTO clientes (nome, cpf_cnpj, telefone, email, endereco, cidade, estado, cep) VALUES
('João da Silva', '123.456.789-00', '(11) 98765-4321', 'joao@email.com', 'Rua A, 123', 'São Paulo', 'SP', '01234-567'),
('Maria Santos', '987.654.321-00', '(11) 91234-5678', 'maria@email.com', 'Av B, 456', 'São Paulo', 'SP', '01234-890');

-- Inserir veículos
INSERT INTO veiculos (id_cliente, placa, marca, modelo, ano_fabricacao, ano_modelo, cor) VALUES
(1, 'ABC-1234', 'Volkswagen', 'Gol', 2020, 2021, 'Prata'),
(2, 'XYZ-9876', 'Fiat', 'Uno', 2019, 2020, 'Branco');

-- Inserir mecânicos
INSERT INTO mecanicos (codigo, nome, endereco, telefone, especialidade, data_admissao) VALUES
('MEC001', 'Carlos Ferreira', 'Rua C, 789', '(11) 99999-1111', 'Motor', '2020-01-15'),
('MEC002', 'Pedro Oliveira', 'Rua D, 321', '(11) 99999-2222', 'Suspensão', '2021-03-20'),
('MEC003', 'Lucas Costa', 'Rua E, 654', '(11) 99999-3333', 'Elétrica', '2021-06-10');

-- Inserir equipes
INSERT INTO equipes (nome_equipe, descricao) VALUES
('Equipe A', 'Equipe especializada em manutenção geral'),
('Equipe B', 'Equipe especializada em motor e transmissão');

-- Associar mecânicos às equipes
INSERT INTO equipe_mecanicos (id_equipe, id_mecanico, data_entrada) VALUES
(1, 1, '2020-01-15'),
(1, 2, '2021-03-20'),
(2, 1, '2020-01-15'),
(2, 3, '2021-06-10');

-- Inserir serviços no catálogo
INSERT INTO catalogo_servicos (codigo_servico, descricao, categoria) VALUES
('SERV001', 'Troca de óleo e filtro', 'Manutenção Preventiva'),
('SERV002', 'Alinhamento e balanceamento', 'Suspensão'),
('SERV003', 'Revisão de freios', 'Freios'),
('SERV004', 'Troca de correia dentada', 'Motor');

-- Inserir valores na tabela de mão-de-obra
INSERT INTO tabela_mao_obra (id_servico, valor_mao_obra, tempo_estimado_horas, data_vigencia_inicio) VALUES
(1, 80.00, 1.0, '2024-01-01'),
(2, 120.00, 2.0, '2024-01-01'),
(3, 150.00, 2.5, '2024-01-01'),
(4, 350.00, 4.0, '2024-01-01');

-- Inserir peças no catálogo
INSERT INTO catalogo_pecas (codigo_peca, descricao, marca, valor_unitario, estoque_atual, estoque_minimo) VALUES
('PEC001', 'Óleo de motor 5W30 - 1L', 'Castrol', 35.00, 50, 10),
('PEC002', 'Filtro de óleo', 'Mann', 25.00, 30, 5),
('PEC003', 'Pastilha de freio dianteira', 'Bosch', 85.00, 20, 5),
('PEC004', 'Correia dentada', 'Gates', 180.00, 10, 3);