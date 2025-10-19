# Documentação do Esquema Conceitual - Sistema de Oficina Mecânica

## 1. Introdução

### 1.1 Objetivo
Apresentar o **esquema conceitual** (modelo ER - Entidade-Relacionamento) do sistema de gerenciamento de ordens de serviço para oficina mecânica, descrevendo entidades, atributos, relacionamentos e regras de negócio.

### 1.2 Metodologia
- **Notação:** Modelo Entidade-Relacionamento (MER)
- **Abordagem:** Top-down (do conceitual para o lógico)
- **Nível de Abstração:** Conceitual (independente de implementação)

---

## 2. Identificação de Entidades

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

### 2.1 Entidades Principais

#### CLIENTE
Representa os proprietários de veículos que utilizam os serviços da oficina.

**Atributos:**
- **id_cliente** (Identificador) - PK
- nome - obrigatório
- cpf_cnpj - único, obrigatório
- telefone
- email
- endereco_completo (composto):
  - endereco
  - cidade
  - estado
  - cep
- data_cadastro - derivado (timestamp automático)

**Características:**
- Cada cliente pode possuir múltiplos veículos
- CPF/CNPJ deve ser único no sistema

---

#### VEICULO
Representa os veículos atendidos pela oficina.

**Atributos:**
- **id_veiculo** (Identificador) - PK
- placa - único, obrigatório
- marca - obrigatório
- modelo - obrigatório
- ano_fabricacao
- ano_modelo
- cor
- data_cadastro - derivado

**Características:**
- Cada veículo pertence a um único cliente
- Placa é identificador alternativo (único)
- Um veículo pode ter múltiplas OS ao longo do tempo

---

#### MECANICO
Representa os profissionais que executam os serviços.

**Atributos:**
- **id_mecanico** (Identificador) - PK
- codigo - único, obrigatório
- nome - obrigatório
- endereco_completo (composto):
  - endereco
  - cidade
  - estado
  - cep
- telefone
- especialidade
- data_admissao
- salario
- status - enumerado ('Ativo', 'Inativo', 'Férias')

**Características:**
- Código é identificador funcional único
- Um mecânico pode participar de múltiplas equipes
- Possui especialidade técnica definida

---

#### EQUIPE
Representa grupos de trabalho que atendem veículos.

**Atributos:**
- **id_equipe** (Identificador) - PK
- nome_equipe - obrigatório
- descricao
- data_criacao - derivado

**Características:**
- Composta por um ou mais mecânicos
- Responsável por avaliar e executar serviços (regra de negócio)
- Uma equipe pode atender múltiplas OS simultaneamente

---

#### ORDEM_SERVICO (OS)
Entidade central que representa uma ordem de trabalho.

**Atributos:**
- **numero_os** (Identificador) - PK
- data_emissao - obrigatório
- data_conclusao_prevista - obrigatório
- data_conclusao_real
- data_autorizacao
- valor_total - derivado (calculado)
- valor_mao_obra - derivado (calculado)
- valor_pecas - derivado (calculado)
- status - enumerado, obrigatório
  - 'Aguardando Autorização' (padrão)
  - 'Autorizada'
  - 'Em Execução'
  - 'Concluída'
  - 'Cancelada'
- observacoes

**Características:**
- Número da OS é gerado automaticamente (sequencial)
- Valores são calculados a partir dos serviços e peças
- Cliente deve autorizar antes da execução

---

#### CATALOGO_SERVICO
Representa o catálogo de serviços oferecidos.

**Atributos:**
- **id_servico** (Identificador) - PK
- codigo_servico - único, obrigatório
- descricao - obrigatório
- categoria

**Características:**
- Representa tipos de serviços (não execuções específicas)
- Um serviço pode ser executado em múltiplas OS
- Código do serviço é identificador de negócio

---

#### TABELA_MAO_OBRA
Tabela de referência de preços de serviços com histórico.

**Atributos:**
- **id_tabela** (Identificador) - PK
- valor_mao_obra - obrigatório
- tempo_estimado_horas
- data_vigencia_inicio - obrigatório
- data_vigencia_fim

**Características:**
- Mantém histórico de preços por período
- Vigência atual quando data_vigencia_fim = NULL
- Permite consultar preços em qualquer data histórica

---

#### CATALOGO_PECA
Representa o catálogo de peças disponíveis.

**Atributos:**
- **id_peca** (Identificador) - PK
- codigo_peca - único, obrigatório
- descricao - obrigatório
- marca
- valor_unitario - obrigatório
- estoque_atual - obrigatório, padrão 0
- estoque_minimo - padrão 0

**Características:**
- Controla estoque de peças
- Estoque é atualizado automaticamente ao vincular à OS
- Código da peça é identificador de negócio

---

## 3. Relacionamentos

### 3.1 CLIENTE possui VEICULO
**Tipo:** 1:N (um para muitos)  
**Cardinalidade:** (1,N) : (1,1)

**Descrição:**
- Um cliente pode possuir um ou mais veículos
- Um veículo pertence a exatamente um cliente

**Participação:**
- CLIENTE: parcial (pode existir cliente sem veículo cadastrado)
- VEICULO: total (todo veículo deve ter proprietário)

---

### 3.2 VEICULO gera ORDEM_SERVICO
**Tipo:** 1:N (um para muitos)  
**Cardinalidade:** (1,N) : (1,1)

**Descrição:**
- Um veículo pode gerar várias ordens de serviço ao longo do tempo
- Uma OS é criada para exatamente um veículo

**Participação:**
- VEICULO: parcial (veículo pode estar cadastrado sem OS)
- ORDEM_SERVICO: total (toda OS deve estar vinculada a um veículo)

---

### 3.3 EQUIPE é responsável por ORDEM_SERVICO
**Tipo:** 1:N (um para muitos)  
**Cardinalidade:** (1,N) : (1,1)

**Descrição:**
- Uma equipe pode ser responsável por várias OS
- Uma OS é atribuída a exatamente uma equipe

**Participação:**
- EQUIPE: parcial (equipe pode existir sem OS atribuída)
- ORDEM_SERVICO: total (toda OS deve ter equipe responsável)

**Regra de Negócio:** A mesma equipe que avalia também executa os serviços.

---

### 3.4 MECANICO compõe EQUIPE
**Tipo:** N:N (muitos para muitos)  
**Cardinalidade:** (1,N) : (1,N)

**Descrição:**
- Um mecânico pode participar de várias equipes
- Uma equipe é composta por vários mecânicos

**Participação:**
- MECANICO: parcial (mecânico pode estar sem equipe temporariamente)
- EQUIPE: total (toda equipe deve ter ao menos um mecânico)

**Atributos do Relacionamento:**
- data_entrada - data em que o mecânico entrou na equipe

**Entidade Associativa:** EQUIPE_MECANICO

---

### 3.5 ORDEM_SERVICO contém CATALOGO_SERVICO
**Tipo:** N:N (muitos para muitos)  
**Cardinalidade:** (1,N) : (1,N)

**Descrição:**
- Uma OS pode conter vários serviços
- Um serviço (do catálogo) pode estar presente em várias OS

**Participação:**
- ORDEM_SERVICO: parcial (OS pode estar em criação sem serviços)
- CATALOGO_SERVICO: parcial (serviço pode existir sem ser executado)

**Atributos do Relacionamento:**
- valor_mao_obra - valor cobrado nesta OS (pode diferir da tabela)
- tempo_execucao_horas - tempo real gasto
- observacoes - observações específicas desta execução

**Entidade Associativa:** OS_SERVICO

**Regra de Negócio:** Valor consultado na TABELA_MAO_OBRA, mas pode ser ajustado.

---

### 3.6 ORDEM_SERVICO utiliza CATALOGO_PECA
**Tipo:** N:N (muitos para muitos)  
**Cardinalidade:** (0,N) : (0,N)

**Descrição:**
- Uma OS pode utilizar várias peças
- Uma peça (do catálogo) pode ser utilizada em várias OS

**Participação:**
- ORDEM_SERVICO: parcial (OS pode não necessitar de peças)
- CATALOGO_PECA: parcial (peça pode estar em estoque sem uso)

**Atributos do Relacionamento:**
- quantidade - quantidade utilizada (obrigatório)
- valor_unitario - valor cobrado por unidade
- valor_total - derivado (quantidade × valor_unitario)

**Entidade Associativa:** OS_PECA

**Regra de Negócio:** Estoque é decrementado automaticamente ao adicionar peça à OS.

---

### 3.7 CATALOGO_SERVICO tem TABELA_MAO_OBRA
**Tipo:** 1:N (um para muitos)  
**Cardinalidade:** (1,1) : (1,N)

**Descrição:**
- Um serviço pode ter vários registros de preço ao longo do tempo (histórico)
- Cada registro de preço refere-se a exatamente um serviço

**Participação:**
- CATALOGO_SERVICO: total (todo serviço deve ter pelo menos um preço)
- TABELA_MAO_OBRA: total (todo registro de preço deve referenciar um serviço)

**Regra de Negócio:** Mantém histórico de valores por período de vigência.

---

## 4. Diagrama ER

<p align="center">
  <img src="/images/projeto03/oficina_mecanica_ER.png" alt="Projeto Oficina Mecânica" style="max-width: 100%;">
  <br>
  <em>Figura 1 - Diagrama Entidade Relacionamento - Projeto Oficina Mecânica</em>
</p>

```
┌─────────────┐
│   CLIENTE   │
└──────┬──────┘
       │ (1,N)
       │ possui
       │ (1,1)
┌──────▼──────┐         ┌──────────────────┐
│   VEICULO   │─────────│  ORDEM_SERVICO   │
└─────────────┘ (1,N)   └────────┬─────────┘
                gera             │
                (1,1)            │ (1,1)
                                 │ é responsável por
                        ┌────────▼─────────┐
                        │      EQUIPE      │
                        └────────┬─────────┘
                                 │ (1,N)
                                 │ compõe
                        ┌────────▼─────────┐
                        │ EQUIPE_MECANICO  │ (entidade associativa)
                        └────────┬─────────┘
                                 │ (1,N)
                        ┌────────▼─────────┐
                        │    MECANICO      │
                        └──────────────────┘

┌──────────────────┐          ┌─────────────┐
│ CATALOGO_SERVICO │──────────│ OS_SERVICO  │ (entidade associativa)
└────────┬─────────┘  (1,N)   └──────┬──────┘
         │                            │ (1,N)
         │ (1,1)                      │
         │ tem                        │
         │ (1,N)          ┌───────────▼────────┐
┌────────▼─────────┐      │  ORDEM_SERVICO     │
│TABELA_MAO_OBRA   │      └───────────┬────────┘
└──────────────────┘                  │ (0,N)
                                      │ utiliza
                         ┌────────────▼───────┐
                         │      OS_PECA       │ (entidade associativa)
                         └────────────┬───────┘
                                      │ (0,N)
                         ┌────────────▼───────┐
                         │   CATALOGO_PECA    │
                         └────────────────────┘
```

---

## 5. Cardinalidades Resumidas

| Relacionamento | Entidade A | Cardinalidade | Entidade B | Tipo |
|----------------|------------|---------------|------------|------|
| possui | CLIENTE (1,N) | ↔ | VEICULO (1,1) | 1:N |
| gera | VEICULO (1,N) | ↔ | ORDEM_SERVICO (1,1) | 1:N |
| é responsável por | EQUIPE (1,N) | ↔ | ORDEM_SERVICO (1,1) | 1:N |
| compõe | MECANICO (1,N) | ↔ | EQUIPE (1,N) | N:N |
| contém | ORDEM_SERVICO (1,N) | ↔ | CATALOGO_SERVICO (1,N) | N:N |
| utiliza | ORDEM_SERVICO (0,N) | ↔ | CATALOGO_PECA (0,N) | N:N |
| tem | CATALOGO_SERVICO (1,1) | ↔ | TABELA_MAO_OBRA (1,N) | 1:N |

---

## 6. Regras de Negócio Identificadas

### RN01 - Unicidade de Identificadores
- CPF/CNPJ de cliente deve ser único
- Placa de veículo deve ser única
- Código de mecânico deve ser único
- Código de serviço deve ser único
- Código de peça deve ser único

### RN02 - Obrigatoriedade de Dados
- Todo veículo deve ter proprietário (cliente)
- Toda OS deve estar vinculada a um veículo e uma equipe
- Toda OS deve ter data de emissão e data de conclusão prevista

### RN03 - Autorização de Serviços
- Cliente deve autorizar a OS antes da execução
- Autorização registrada em data_autorizacao
- Status muda de 'Aguardando Autorização' para 'Autorizada'

### RN04 - Execução de Serviços
- A mesma equipe que avalia também executa os serviços
- Equipe deve ter ao menos um mecânico

### RN05 - Cálculo de Valores
- Valor da mão-de-obra consultado na tabela de referência
- Valor das peças compõe o valor total da OS
- Valor total da OS = valor_mao_obra + valor_pecas
- Valores calculados automaticamente

### RN06 - Controle de Estoque
- Estoque decrementado ao adicionar peça à OS
- Estoque incrementado ao remover peça da OS
- Alerta quando estoque_atual ≤ estoque_minimo

### RN07 - Ciclo de Vida da OS
Sequência de status:
1. 'Aguardando Autorização' (criação)
2. 'Autorizada' (após autorização do cliente)
3. 'Em Execução' (durante trabalho)
4. 'Concluída' ou 'Cancelada' (finalização)

### RN08 - Histórico de Preços
- Tabela de mão-de-obra mantém histórico por vigência
- Preço vigente: data_vigencia_fim = NULL
- Permite consultar preços históricos

### RN09 - Multiplicidade de Serviços e Peças
- Uma OS pode ter múltiplos serviços
- Um serviço pode aparecer em múltiplas OS
- Uma OS pode ter múltiplas peças
- Uma peça pode ser usada em múltiplas OS

### RN10 - Especialização de Mecânicos
- Cada mecânico possui especialidade definida
- Mecânico pode estar em múltiplas equipes
- Status do mecânico: Ativo, Inativo ou Férias

---

## 7. Atributos Derivados

| Entidade | Atributo Derivado | Fórmula/Origem |
|----------|-------------------|----------------|
| CLIENTE | data_cadastro | TIMESTAMP automático na criação |
| VEICULO | data_cadastro | TIMESTAMP automático na criação |
| EQUIPE | data_criacao | TIMESTAMP automático na criação |
| ORDEM_SERVICO | valor_mao_obra | SUM(OS_SERVICO.valor_mao_obra) |
| ORDEM_SERVICO | valor_pecas | SUM(OS_PECA.valor_total) |
| ORDEM_SERVICO | valor_total | valor_mao_obra + valor_pecas |
| OS_PECA | valor_total | quantidade × valor_unitario |

---

## 8. Atributos Compostos

### endereco_completo
Presente em CLIENTE e MECANICO:
- endereco (logradouro)
- cidade
- estado (UF)
- cep

**Justificativa:** Endereço é uma informação composta que pode ser decomposta em componentes atômicos no modelo lógico.

---

## 9. Atributos Multivalorados

**Não identificados no sistema.**

Todos os atributos são monovalorados. Relacionamentos N:N são tratados através de entidades associativas.

---

## 10. Entidades Fracas

**Não identificadas no sistema.**

Todas as entidades possuem identificador próprio independente de outras entidades.

---

## 11. Especialização/Generalização

**Não identificada no escopo atual.**

Possíveis extensões futuras:
- PESSOA (generalização) → CLIENTE, MECANICO (especializações)
- SERVICO → SERVICO_PREVENTIVO, SERVICO_CORRETIVO

---

## 12. Restrições de Integridade

### Integridade de Entidade
- Todas as entidades possuem chave primária definida
- Chaves primárias não podem ser nulas

### Integridade Referencial
- Todas as chaves estrangeiras devem referenciar registros existentes
- Deleções devem seguir política definida:
  - CLIENTE: não permitir se houver veículos associados
  - VEICULO: não permitir se houver OS associadas
  - EQUIPE: não permitir se houver OS em andamento
  - MECANICO: remover de equipes antes de deletar
  - CATALOGO_SERVICO: não permitir se houver OS_SERVICO
  - CATALOGO_PECA: não permitir se houver OS_PECA

### Integridade de Domínio
- status (ORDEM_SERVICO): apenas valores do enum definido
- status (MECANICO): apenas valores do enum definido
- estoque_atual: não pode ser negativo
- quantidade (OS_PECA): deve ser maior que zero
- valores monetários: não podem ser negativos

### Restrições de Negócio
- data_conclusao_prevista ≥ data_emissao
- data_conclusao_real ≥ data_emissao
- data_vigencia_fim ≥ data_vigencia_inicio (quando não nulo)
- Não pode haver dois preços vigentes simultaneamente para o mesmo serviço

---

## 13. Dicionário de Dados Resumido

### Tipos de Dados Conceituais

| Tipo | Descrição | Exemplos |
|------|-----------|----------|
| Identificador | Número inteiro único auto-incrementado | id_cliente, numero_os |
| Texto Curto | String até 100 caracteres | nome, marca, modelo |
| Texto Médio | String até 200 caracteres | descricao, endereco |
| Texto Longo | String sem limite específico | observacoes |
| Numérico Decimal | Números com casas decimais | valor_total, salario |
| Data | Data no formato YYYY-MM-DD | data_emissao, data_admissao |
| Data/Hora | Data e hora | data_autorizacao |
| Enumerado | Lista fechada de valores | status (OS), status (mecânico) |
| Booleano | Verdadeiro/Falso | Não utilizado |

---

## 14. Normalização Conceitual

O modelo conceitual já considera princípios de normalização:

### Primeira Forma Normal (1FN)
- Todos os atributos são atômicos
- Não há grupos repetitivos
- Relacionamentos N:N tratados via entidades associativas

### Segunda Forma Normal (2FN)
- Todas as entidades possuem chave primária
- Atributos não-chave dependem completamente da chave

### Terceira Forma Normal (3FN)
- Não há dependências transitivas
- TABELA_MAO_OBRA separada de CATALOGO_SERVICO para histórico
- Catálogos separados das execuções (CATALOGO_SERVICO vs OS_SERVICO)

---

## 15. Casos de Uso Principais

### UC01 - Cadastrar Cliente e Veículo
**Entidades:** CLIENTE, VEICULO  
**Relacionamento:** possui

### UC02 - Criar Ordem de Serviço
**Entidades:** ORDEM_SERVICO, VEICULO, EQUIPE  
**Relacionamentos:** gera, é responsável por

### UC03 - Adicionar Serviços à OS
**Entidades:** ORDEM_SERVICO, CATALOGO_SERVICO, OS_SERVICO  
**Relacionamento:** contém

### UC04 - Adicionar Peças à OS
**Entidades:** ORDEM_SERVICO, CATALOGO_PECA, OS_PECA  
**Relacionamento:** utiliza

### UC05 - Autorizar OS
**Entidades:** ORDEM_SERVICO  
**Regra:** RN03 - Autorização de Serviços

### UC06 - Executar e Concluir OS
**Entidades:** ORDEM_SERVICO  
**Regra:** RN07 - Ciclo de Vida da OS

### UC07 - Consultar Preço de Serviço
**Entidades:** CATALOGO_SERVICO, TABELA_MAO_OBRA  
**Relacionamento:** tem

### UC08 - Gerenciar Equipes
**Entidades:** EQUIPE, MECANICO, EQUIPE_MECANICO  
**Relacionamento:** compõe

---

## 16. Matriz CRUD

| Entidade | Create | Read | Update | Delete |
|----------|--------|------|--------|--------|
| CLIENTE | ✓ | ✓ | ✓ | ✓* |
| VEICULO | ✓ | ✓ | ✓ | ✓* |
| MECANICO | ✓ | ✓ | ✓ | ✓* |
| EQUIPE | ✓ | ✓ | ✓ | ✓* |
| EQUIPE_MECANICO | ✓ | ✓ | ✓ | ✓ |
| CATALOGO_SERVICO | ✓ | ✓ | ✓ | ✓* |
| TABELA_MAO_OBRA | ✓ | ✓ | ✓ | ✗ |
| CATALOGO_PECA | ✓ | ✓ | ✓ | ✓* |
| ORDEM_SERVICO | ✓ | ✓ | ✓ | ✗** |
| OS_SERVICO | ✓ | ✓ | ✓ | ✓ |
| OS_PECA | ✓ | ✓ | ✓ | ✓ |

**Legenda:**
- ✓ = Permitido
- ✗ = Não permitido
- ✓* = Permitido com restrições
- ✗** = Usar cancelamento lógico (status = 'Cancelada')

---

## Scripts SQL

Script SQL contendo criação do Schema de banco de dados, criação das tabelas, insert de exemplos e Triggers para automação de valores:

[Criação do Banco de Dados Oficina Mecânica](/scripts/projeto03/create_db_oficina_mecanica.sql)
