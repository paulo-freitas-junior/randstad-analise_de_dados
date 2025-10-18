-- =====================================================
-- CONSULTAS ÚTEIS APÓS INSERÇÃO
-- =====================================================

-- Ver todos os clientes PF
SELECT 
    c.idCliente,
    pf.cli_Nome,
    pf.cli_CPF,
    DATE_FORMAT(pf.cli_DataNascimento, '%d/%m/%Y') as data_nascimento,
    c.cli_Email,
    c.cli_ContatoTelefone,
    DATE_FORMAT(c.cli_DataCadastro, '%d/%m/%Y %H:%i:%s') as data_cadastro
FROM clientes c
JOIN clientes_pf pf ON c.idCliente = pf.idCliente
WHERE c.cli_Ativo = TRUE
ORDER BY c.cli_DataCadastro DESC;

-- Ver todos os clientes PJ
SELECT 
    c.idCliente,
    pj.cli_RazaoSocial,
    pj.cli_NomeFantasia,
    pj.cli_CNPJ,
    pj.cli_InscricaoEstadual,
    c.cli_Email,
    c.cli_ContatoTelefone,
    DATE_FORMAT(c.cli_DataCadastro, '%d/%m/%Y %H:%i:%s') as data_cadastro
FROM clientes c
JOIN clientes_pj pj ON c.idCliente = pj.idCliente
WHERE c.cli_Ativo = TRUE
ORDER BY c.cli_DataCadastro DESC;

-- Ver todos os clientes (PF e PJ unificados)
SELECT 
    c.idCliente,
    c.cli_TipoCliente,
    COALESCE(pf.cli_Nome, pj.cli_RazaoSocial) as nome,
    COALESCE(pf.cli_CPF, pj.cli_CNPJ) as documento,
    c.cli_Email,
    c.cli_ContatoTelefone,
    c.cli_Endereco,
    DATE_FORMAT(c.cli_DataCadastro, '%d/%m/%Y %H:%i:%s') as data_cadastro
FROM clientes c
LEFT JOIN clientes_pf pf ON c.idCliente = pf.idCliente
LEFT JOIN clientes_pj pj ON c.idCliente = pj.idCliente
WHERE c.cli_Ativo = TRUE
ORDER BY c.cli_DataCadastro DESC;