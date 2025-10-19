# Documentação Técnica - Sistema de Gerenciamento de Oficina Mecânica

## 1. Visão Geral do Sistema

Sistema de controle e gerenciamento de execução de ordens de serviço em oficina mecânica, permitindo o controle completo desde a entrada do veículo até a conclusão dos serviços, incluindo gestão de equipes, peças, serviços e valores.

### 1.1 Tecnologias Utilizadas
- **SGBD:** MySQL 8.0+
- **Engine:** InnoDB (suporte a transações e integridade referencial)
- **Charset:** UTF8MB4 (suporte completo a caracteres especiais)

---

## 2. Arquitetura do Banco de Dados

### 2.1 Estrutura de Tabelas

O banco de dados está organizado em 11 tabelas principais divididas em 3 categorias:

**Entidades Principais:**
- clientes
- veiculos
- mecanicos
- equipes
- ordens_servico

**Catálogos e Referências:**
- catalogo_servicos
- catalogo_pecas
- tabela_mao_obra

**Relacionamentos (Tabelas Associativas):**
- equipe_mecanicos
- os_servicos
- os_pecas

<p align="center">
  <img src="/images/projeto03/oficina_mecanica_ER.png" alt="Projeto Oficina Mecânica" style="max-width: 100%;">
  <br>
  <em>Figura 2 - Diagrama Entidade Relacionamento - Projeto Oficina Mecânica</em>
</p>

---

## 3. Descrição Detalhada das Tabelas

### 3.1 CLIENTES
Armazena informações dos clientes da oficina.

**Campos:**
- `id_cliente` (PK, AUTO_INCREMENT): Identificador único
- `nome` (VARCHAR 100, NOT NULL): Nome completo
- `cpf_cnpj` (VARCHAR 18, UNIQUE, NOT NULL): Documento único
- `telefone` (VARCHAR 20): Telefone de contato
- `email` (VARCHAR 100): E-mail
- `endereco` (VARCHAR 200): Logradouro
- `cidade` (VARCHAR 100): Cidade
- `estado` (CHAR 2): UF
- `cep` (VARCHAR 10): CEP
- `data_cadastro` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP): Data de cadastro

**Índices:**
- PRIMARY KEY: id_cliente
- UNIQUE: cpf_cnpj
- INDEX: cpf_cnpj, nome

---

### 3.2 VEICULOS
Registra os veículos dos clientes.

**Campos:**
- `id_veiculo` (PK, AUTO_INCREMENT): Identificador único
- `id_cliente` (FK, NOT NULL): Referência ao proprietário
- `placa` (VARCHAR 10, UNIQUE, NOT NULL): Placa do veículo
- `marca` (VARCHAR 50, NOT NULL): Fabricante
- `modelo` (VARCHAR 50, NOT NULL): Modelo
- `ano_fabricacao` (YEAR): Ano de fabricação
- `ano_modelo` (YEAR): Ano do modelo
- `cor` (VARCHAR 30): Cor do veículo
- `data_cadastro` (TIMESTAMP): Data de cadastro

**Relacionamentos:**
- FK → clientes(id_cliente)

**Índices:**
- PRIMARY KEY: id_veiculo
- UNIQUE: placa
- INDEX: placa, id_cliente

---

### 3.3 MECANICOS
Cadastro dos mecânicos da oficina.

**Campos:**
- `id_mecanico` (PK, AUTO_INCREMENT): Identificador único
- `codigo` (VARCHAR 20, UNIQUE, NOT NULL): Código funcional
- `nome` (VARCHAR 100, NOT NULL): Nome completo
- `endereco` (VARCHAR 200): Endereço residencial
- `cidade` (VARCHAR 100): Cidade
- `estado` (CHAR 2): UF
- `cep` (VARCHAR 10): CEP
- `telefone` (VARCHAR 20): Telefone
- `especialidade` (VARCHAR 100): Área de especialização
- `data_admissao` (DATE): Data de contratação
- `salario` (DECIMAL 10,2): Salário
- `status` (ENUM): 'Ativo', 'Inativo', 'Férias'

**Índices:**
- PRIMARY KEY: id_mecanico
- UNIQUE: codigo
- INDEX: codigo, especialidade

---

### 3.4 EQUIPES
Organização de equipes de trabalho.

**Campos:**
- `id_equipe` (PK, AUTO_INCREMENT): Identificador único
- `nome_equipe` (VARCHAR 100, NOT NULL): Nome da equipe
- `descricao` (TEXT): Descrição e especialidades
- `data_criacao` (TIMESTAMP): Data de criação

**Relacionamento:** N:N com mecânicos através de equipe_mecanicos

---

### 3.5 EQUIPE_MECANICOS
Tabela associativa entre equipes e mecânicos (relacionamento N:N).

**Campos:**
- `id_equipe` (PK, FK): Referência à equipe
- `id_mecanico` (PK, FK): Referência ao mecânico
- `data_entrada` (DATE, NOT NULL): Data de entrada na equipe

**Chave Primária Composta:** (id_equipe, id_mecanico)

**Relacionamentos:**
- FK → equipes(id_equipe)
- FK → mecanicos(id_mecanico)

**Regra de Negócio:** Um mecânico pode pertencer a múltiplas equipes e uma equipe pode ter vários mecânicos.

---

### 3.6 CATALOGO_SERVICOS
Catálogo de serviços oferecidos pela oficina.

**Campos:**
- `id_servico` (PK, AUTO_INCREMENT): Identificador único
- `codigo_servico` (VARCHAR 20, UNIQUE, NOT NULL): Código do serviço
- `descricao` (VARCHAR 200, NOT NULL): Descrição do serviço
- `categoria` (VARCHAR 50): Categoria (ex: Manutenção Preventiva)

**Índices:**
- PRIMARY KEY: id_servico
- UNIQUE: codigo_servico
- INDEX: codigo_servico

---

### 3.7 TABELA_MAO_OBRA
Tabela de referência de preços de mão-de-obra com histórico.

**Campos:**
- `id_tabela` (PK, AUTO_INCREMENT): Identificador único
- `id_servico` (FK, NOT NULL): Referência ao serviço
- `valor_mao_obra` (DECIMAL 10,2, NOT NULL): Valor cobrado
- `tempo_estimado_horas` (DECIMAL 5,2): Tempo estimado
- `data_vigencia_inicio` (DATE, NOT NULL): Início da vigência
- `data_vigencia_fim` (DATE): Fim da vigência (NULL = vigente)

**Relacionamentos:**
- FK → catalogo_servicos(id_servico)

**Índices:**
- INDEX: (id_servico, data_vigencia_inicio, data_vigencia_fim)

**Regra de Negócio:** Permite histórico de preços. Para obter preço vigente, buscar registro onde data atual esteja entre vigência_inicio e vigência_fim (ou fim seja NULL).

---

### 3.8 CATALOGO_PECAS
Catálogo de peças com controle de estoque.

**Campos:**
- `id_peca` (PK, AUTO_INCREMENT): Identificador único
- `codigo_peca` (VARCHAR 30, UNIQUE, NOT NULL): Código da peça
- `descricao` (VARCHAR 200, NOT NULL): Descrição
- `marca` (VARCHAR 50): Fabricante
- `valor_unitario` (DECIMAL 10,2, NOT NULL): Preço unitário
- `estoque_atual` (INT, DEFAULT 0): Quantidade em estoque
- `estoque_minimo` (INT, DEFAULT 0): Estoque mínimo

**Índices:**
- PRIMARY KEY: id_peca
- UNIQUE: codigo_peca
- INDEX: codigo_peca

**Controle Automático:** Triggers atualizam estoque_atual automaticamente ao adicionar/remover peças de OS.

---

### 3.9 ORDENS_SERVICO
Registro de ordens de serviço.

**Campos:**
- `numero_os` (PK, AUTO_INCREMENT): Número da OS
- `id_veiculo` (FK, NOT NULL): Veículo atendido
- `id_equipe` (FK, NOT NULL): Equipe responsável
- `data_emissao` (DATE, NOT NULL): Data de abertura
- `data_conclusao_prevista` (DATE, NOT NULL): Prazo previsto
- `data_conclusao_real` (DATE): Data real de conclusão
- `valor_total` (DECIMAL 10,2, DEFAULT 0): Valor total (calculado)
- `valor_mao_obra` (DECIMAL 10,2, DEFAULT 0): Total mão-de-obra (calculado)
- `valor_pecas` (DECIMAL 10,2, DEFAULT 0): Total peças (calculado)
- `status` (ENUM): Status da OS
- `observacoes` (TEXT): Observações gerais
- `data_autorizacao` (DATETIME): Data/hora da autorização

**Status Possíveis:**
- 'Aguardando Autorização' (padrão)
- 'Autorizada'
- 'Em Execução'
- 'Concluída'
- 'Cancelada'

**Relacionamentos:**
- FK → veiculos(id_veiculo)
- FK → equipes(id_equipe)

**Índices:**
- INDEX: id_veiculo, status, data_emissao

**Cálculo Automático:** Valores calculados por triggers ao adicionar/atualizar serviços e peças.

---

### 3.10 OS_SERVICOS
Serviços executados em cada OS (relacionamento N:N).

**Campos:**
- `id_os_servico` (PK, AUTO_INCREMENT): Identificador único
- `numero_os` (FK, NOT NULL): Referência à OS
- `id_servico` (FK, NOT NULL): Serviço executado
- `valor_mao_obra` (DECIMAL 10,2, NOT NULL): Valor cobrado (pode diferir da tabela)
- `tempo_execucao_horas` (DECIMAL 5,2): Tempo real de execução
- `observacoes` (TEXT): Observações específicas

**Relacionamentos:**
- FK → ordens_servico(numero_os)
- FK → catalogo_servicos(id_servico)

**Índices:**
- INDEX: numero_os, id_servico

**Regra de Negócio:** Uma OS pode ter vários serviços e um serviço pode aparecer em várias OS.

---

### 3.11 OS_PECAS
Peças utilizadas em cada OS (relacionamento N:N).

**Campos:**
- `id_os_peca` (PK, AUTO_INCREMENT): Identificador único
- `numero_os` (FK, NOT NULL): Referência à OS
- `id_peca` (FK, NOT NULL): Peça utilizada
- `quantidade` (INT, NOT NULL): Quantidade utilizada
- `valor_unitario` (DECIMAL 10,2, NOT NULL): Valor unitário cobrado
- `valor_total` (DECIMAL 10,2, GENERATED, STORED): Calculado automaticamente

**Relacionamentos:**
- FK → ordens_servico(numero_os)
- FK → catalogo_pecas(id_peca)

**Índices:**
- INDEX: numero_os, id_peca

**Coluna Computada:** valor_total = quantidade × valor_unitario (calculado automaticamente pelo MySQL)

**Regra de Negócio:** Uma OS pode ter várias peças e uma peça pode ser usada em várias OS.

---

## 4. Triggers e Automações

### 4.1 Atualização de Valores da OS

**Triggers para os_servicos:**

1. **trg_os_servicos_after_insert**
   - Disparo: AFTER INSERT
   - Ação: Recalcula valor_mao_obra e valor_total da OS

2. **trg_os_servicos_after_update**
   - Disparo: AFTER UPDATE
   - Ação: Recalcula valor_mao_obra e valor_total da OS

3. **trg_os_servicos_after_delete**
   - Disparo: AFTER DELETE
   - Ação: Recalcula valor_mao_obra e valor_total da OS

**Triggers para os_pecas:**

4. **trg_os_pecas_after_insert**
   - Disparo: AFTER INSERT
   - Ações:
     - Recalcula valor_pecas e valor_total da OS
     - Decrementa estoque_atual da peça

5. **trg_os_pecas_after_update**
   - Disparo: AFTER UPDATE
   - Ações:
     - Recalcula valor_pecas e valor_total da OS
     - Ajusta estoque (devolve OLD.quantidade e retira NEW.quantidade)

6. **trg_os_pecas_after_delete**
   - Disparo: AFTER DELETE
   - Ações:
     - Recalcula valor_pecas e valor_total da OS
     - Devolve quantidade ao estoque

### 4.2 Fórmulas de Cálculo

```
valor_mao_obra = SUM(os_servicos.valor_mao_obra) WHERE numero_os = X
valor_pecas = SUM(os_pecas.valor_total) WHERE numero_os = X
valor_total = valor_mao_obra + valor_pecas
```

---

## 5. Views

### 5.1 vw_ordens_servico_completas
Visão consolidada das ordens de serviço com informações relacionadas.

**Campos Retornados:**
- numero_os, data_emissao, data_conclusao_prevista, data_conclusao_real
- status, valor_total
- cliente_nome, cliente_telefone
- placa, marca, modelo
- nome_equipe

**Uso:** Listagem e consulta rápida de OS com dados de cliente e veículo.

**Query Exemplo:**
```sql
SELECT * FROM vw_ordens_servico_completas WHERE status = 'Em Execução';
```

---

### 5.2 vw_pecas_estoque_baixo
Identifica peças com estoque abaixo do mínimo.

**Campos Retornados:**
- codigo_peca, descricao, marca
- estoque_atual, estoque_minimo
- quantidade_repor (estoque_minimo - estoque_atual)

**Uso:** Controle de reposição de estoque.

**Query Exemplo:**
```sql
SELECT * FROM vw_pecas_estoque_baixo ORDER BY quantidade_repor DESC;
```

---

## 6. Fluxo de Processos

### 6.1 Fluxo de Criação de OS

1. Cliente leva veículo à oficina
2. Veículo é atribuído a uma equipe
3. Sistema cria OS com status 'Aguardando Autorização'
4. Equipe identifica serviços necessários
5. Serviços são adicionados à OS (tabela os_servicos)
6. Sistema consulta tabela_mao_obra e calcula valores
7. Peças necessárias são adicionadas (tabela os_pecas)
8. Valores são calculados automaticamente pelos triggers
9. Cliente autoriza a OS (status → 'Autorizada', data_autorizacao preenchida)
10. Equipe executa serviços (status → 'Em Execução')
11. Serviços concluídos (status → 'Concluída', data_conclusao_real preenchida)

### 6.2 Atualização Automática de Estoque

**Ao adicionar peça à OS:**
```
estoque_atual = estoque_atual - quantidade
```

**Ao remover peça da OS:**
```
estoque_atual = estoque_atual + quantidade
```

**Ao atualizar quantidade:**
```
estoque_atual = estoque_atual + quantidade_antiga - quantidade_nova
```

---

## 7. Exemplos de Queries

### 7.1 Criar uma nova OS
```sql
INSERT INTO ordens_servico (id_veiculo, id_equipe, data_emissao, data_conclusao_prevista)
VALUES (1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 3 DAY));
```

### 7.2 Adicionar serviço à OS
```sql
INSERT INTO os_servicos (numero_os, id_servico, valor_mao_obra, observacoes)
VALUES (1, 1, 80.00, 'Troca de óleo sintético');
```

### 7.3 Adicionar peça à OS
```sql
INSERT INTO os_pecas (numero_os, id_peca, quantidade, valor_unitario)
VALUES (1, 1, 4, 35.00);
```

### 7.4 Autorizar OS
```sql
UPDATE ordens_servico 
SET status = 'Autorizada', data_autorizacao = NOW()
WHERE numero_os = 1;
```

### 7.5 Concluir OS
```sql
UPDATE ordens_servico 
SET status = 'Concluída', data_conclusao_real = CURDATE()
WHERE numero_os = 1;
```

### 7.6 Buscar OS de um cliente
```sql
SELECT os.*, v.placa, c.nome
FROM ordens_servico os
INNER JOIN veiculos v ON os.id_veiculo = v.id_veiculo
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
WHERE c.cpf_cnpj = '123.456.789-00';
```

### 7.7 Listar serviços de uma OS
```sql
SELECT cs.descricao, oss.valor_mao_obra, oss.tempo_execucao_horas
FROM os_servicos oss
INNER JOIN catalogo_servicos cs ON oss.id_servico = cs.id_servico
WHERE oss.numero_os = 1;
```

### 7.8 Listar peças de uma OS
```sql
SELECT cp.descricao, osp.quantidade, osp.valor_unitario, osp.valor_total
FROM os_pecas osp
INNER JOIN catalogo_pecas cp ON osp.id_peca = cp.id_peca
WHERE osp.numero_os = 1;
```

### 7.9 Relatório de faturamento mensal
```sql
SELECT 
    DATE_FORMAT(data_emissao, '%Y-%m') AS mes,
    COUNT(*) AS total_os,
    SUM(valor_total) AS faturamento_total,
    SUM(valor_mao_obra) AS receita_servicos,
    SUM(valor_pecas) AS receita_pecas
FROM ordens_servico
WHERE status = 'Concluída'
GROUP BY DATE_FORMAT(data_emissao, '%Y-%m')
ORDER BY mes DESC;
```

### 7.10 Mecânicos por equipe
```sql
SELECT e.nome_equipe, m.nome, m.especialidade
FROM equipes e
INNER JOIN equipe_mecanicos em ON e.id_equipe = em.id_equipe
INNER JOIN mecanicos m ON em.id_mecanico = m.id_mecanico
ORDER BY e.nome_equipe, m.nome;
```

---

## 8. Boas Práticas de Uso

### 8.1 Transações
Sempre use transações ao criar OS complexas:

```sql
START TRANSACTION;

INSERT INTO ordens_servico (...) VALUES (...);
SET @ultimo_os = LAST_INSERT_ID();

INSERT INTO os_servicos (numero_os, ...) VALUES (@ultimo_os, ...);
INSERT INTO os_pecas (numero_os, ...) VALUES (@ultimo_os, ...);

COMMIT;
```

### 8.2 Verificação de Estoque
Antes de adicionar peça, verifique disponibilidade:

```sql
SELECT estoque_atual 
FROM catalogo_pecas 
WHERE id_peca = ? AND estoque_atual >= ?;
```

### 8.3 Consulta de Preço Vigente
Para obter preço atual de mão-de-obra:

```sql
SELECT valor_mao_obra
FROM tabela_mao_obra
WHERE id_servico = ?
  AND data_vigencia_inicio <= CURDATE()
  AND (data_vigencia_fim IS NULL OR data_vigencia_fim >= CURDATE())
ORDER BY data_vigencia_inicio DESC
LIMIT 1;
```

---

## 9. Manutenção e Backup

### 9.1 Backup Regular
```bash
mysqldump -u usuario -p oficina_mecanica > backup_oficina_YYYYMMDD.sql
```

### 9.2 Índices e Performance
- Monitore queries lentas com slow query log
- Analise índices com EXPLAIN
- Considere índices adicionais para relatórios frequentes

### 9.3 Limpeza de Dados
Considere arquivamento de OS antigas (>2 anos) em tabela histórica.

---

## 10. Segurança

### 10.1 Permissões Sugeridas

**Usuário Operacional:**
```sql
GRANT SELECT, INSERT, UPDATE ON oficina_mecanica.* TO 'operador'@'localhost';
```

**Usuário Consulta (Relatórios):**
```sql
GRANT SELECT ON oficina_mecanica.* TO 'relatorios'@'localhost';
```

**Usuário Admin:**
```sql
GRANT ALL PRIVILEGES ON oficina_mecanica.* TO 'admin'@'localhost';
```

### 10.2 Restrições
- Nunca permitir DELETE direto em ordens_servico (usar status 'Cancelada')
- Implementar log de auditoria para alterações críticas
- Proteger acesso direto a tabelas de catálogo

---

## 11. Extensões Futuras

### 11.1 Melhorias Sugeridas
- Tabela de histórico de status da OS
- Sistema de comissões para mecânicos
- Gestão de garantia de serviços
- Agendamento de revisões preventivas
- Integração com sistema de pagamento
- Notas fiscais eletrônicas
- Dashboard analítico
- Aplicativo mobile para acompanhamento

### 11.2 Otimizações
- Particionamento de tabela ordens_servico por ano
- Cache de consultas frequentes
- Índices full-text para busca de descrições
- Arquivamento automático de dados antigos

---

**Versão:** 1.0  
**Data:** Outubro 2025  
**Autor:** Documentação Técnica - Sistema Oficina Mecânica