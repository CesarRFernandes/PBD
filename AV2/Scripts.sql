--Cliente scripts
-- INSERT: Adiciona um novo cliente
INSERT INTO Cliente (nome, cpf, telefone, cep, data_nascimento)
VALUES ('Ana Carolina', '111.222.333-44', '21987654321', '22050-002', '1990-08-15');

-- UPDATE: Atualiza o telefone de um cliente específico
UPDATE Cliente
SET telefone = '21999998888'
WHERE cliente_id = 1;

-- DELETE: Remove um cliente do sistema
DELETE FROM Cliente
WHERE cliente_id = 1;

-- Selecionar TODOS os clientes
SELECT * FROM Cliente ORDER BY nome;

-- Selecionar APENAS UM cliente pelo seu ID
SELECT * FROM Cliente WHERE cliente_id = 1;


--Quarto scripts
-- INSERT: Adiciona novos quartos
INSERT INTO Quarto (numero, capacidade, banheiro, janela, descricao)
VALUES ('101', 4, TRUE, TRUE, 'Quarto com vista para a rua principal e banheiro privativo.');
INSERT INTO Quarto (numero, capacidade, banheiro, janela, descricao)
VALUES ('201', 8, FALSE, FALSE, 'Quarto amplo no segundo andar, sem banheiro privativo.');

-- UPDATE: Modifica a descrição de um quarto
UPDATE Quarto
SET descricao = 'Quarto com vista para a rua principal, banheiro privativo e ar-condicionado.'
WHERE quarto_id = 1;

-- DELETE: Remove um quarto
-- (Atenção: Falhará se houver vagas cadastradas para este quarto)
DELETE FROM Quarto
WHERE quarto_id = 2;

-- Selecionar TODOS os quartos
SELECT * FROM Quarto ORDER BY numero;

-- Selecionar APENAS UM quarto pelo seu ID
SELECT * FROM Quarto WHERE quarto_id = 1;


--Vaga scripts
-- INSERT: Adiciona novas vagas nos quartos criados acima
INSERT INTO Vaga (quarto_id, cama, local, descricao)
VALUES (1, 'Beliche Inferior', 'Perto da Janela', 'Vaga com tomada individual 220V.');
INSERT INTO Vaga (quarto_id, cama, local, descricao)
VALUES (1, 'Beliche Superior', 'Perto da Janela', 'Vaga com luz de leitura individual.');
-- ex.: Quarto 201 (quarto_id = 2)
INSERT INTO Vaga (quarto_id, cama, local, descricao)
VALUES (2, 'Cama Simples', 'Perto da Porta', 'Acesso fácil ao corredor e banheiros comuns.');

-- UPDATE: Altera a descrição de uma vaga
UPDATE Vaga
SET descricao = 'Vaga com tomada individual 220V e cortina de privacidade.'
WHERE vaga_id = 1;

-- DELETE: Remove uma vaga específica
DELETE FROM Vaga
WHERE vaga_id = 3;

-- Selecionar TODAS as vagas (com detalhes do quarto para melhor visualização)
SELECT v.*, q.numero as numero_quarto, q.banheiro as quarto_com_banheiro
FROM Vaga v
JOIN Quarto q ON v.quarto_id = q.quarto_id
ORDER BY q.numero, v.cama;

-- Selecionar APENAS UMA vaga pelo seu ID (com detalhes do quarto)
SELECT v.*, q.numero as numero_quarto, q.descricao as descricao_quarto
FROM Vaga v
JOIN Quarto q ON v.quarto_id = q.quarto_id
WHERE v.vaga_id = 1;


--Reserva scripts
-- INSERT: Cria uma nova reserva para um cliente em uma vaga
INSERT INTO Reserva (cliente_id, vaga_id, data_chegada, data_saida, total_reserva, status)
VALUES (1, 1, '2025-10-20', '2025-10-25', 450.00, 'Pendente');

-- UPDATE: Confirma uma reserva após o pagamento
UPDATE Reserva
SET status = 'Confirmada'
WHERE reserva_id = 1;

-- DELETE: Remove um registro de reserva
DELETE FROM Reserva
WHERE reserva_id = 1;

-- Selecionar TODAS as reservas (com detalhes do cliente e da vaga)
SELECT r.*, c.nome as nome_cliente, v.descricao as descricao_vaga, q.numero as numero_quarto
FROM Reserva r
JOIN Cliente c ON r.cliente_id = c.cliente_id
JOIN Vaga v ON r.vaga_id = v.vaga_id
JOIN Quarto q ON v.quarto_id = q.quarto_id
ORDER BY r.data_chegada DESC;

-- Selecionar APENAS UMA reserva pelo seu ID
SELECT * FROM Reserva WHERE reserva_id = 1;


--Pagamento scripts
-- INSERT: Registra um pagamento para uma reserva existente
INSERT INTO Pagamento (reserva_id, valor, data_transacao, status, tipo_pagamento)
VALUES (1, 450.00, CURRENT_TIMESTAMP, 'Aprovado', 'Cartão de Crédito');

-- UPDATE: Altera o status de um pagamento (ex: de recusado para aprovado após nova tentativa)
UPDATE Pagamento
SET status = 'Aprovado'
WHERE pagamento_id = 1;

-- DELETE: Remove um registro de pagamento
DELETE FROM Pagamento
WHERE pagamento_id = 1;

-- Selecionar TODOS os pagamentos
SELECT * FROM Pagamento ORDER BY data_transacao DESC;

-- Selecionar APENAS UM pagamento pelo seu ID
SELECT * FROM Pagamento WHERE pagamento_id = 1;


-- Mostra as vagas disponíveis em determinado dia e as camas já reservadas.
DO $$
DECLARE
    data_chegada_desejada DATE := '2025-10-22';
    data_saida_desejada   DATE := '2025-10-26';
BEGIN

    --Tabela temporária para guardar o resultado
    CREATE TEMP TABLE IF NOT EXISTS ResultadoDisponibilidade AS
    SELECT
        q.numero AS numero_do_quarto,
        q.banheiro AS quarto_tem_banheiro,
        v.vaga_id,
        v.cama,
        v.local,
        v.descricao AS detalhes_da_vaga,
        --Verificar se a vaga não tem reserva conflitante, se está disponível
        CASE
            WHEN r.reserva_id IS NULL THEN 'Disponível'
            ELSE 'Reservada'
        END AS disponibilidade,
        --Informações da reserva, caso exista
        r.reserva_id AS id_reserva_conflitante,
        r.data_chegada AS inicio_reserva_existente,
        r.data_saida AS fim_reserva_existente
    FROM
        Vaga v
    JOIN
        Quarto q ON v.quarto_id = q.quarto_id
    LEFT JOIN
        --Tenta encontrar uma reserva CONFIRMADA que se sobreponha às datas desejadas
        Reserva r ON v.vaga_id = r.vaga_id
        AND r.status = 'Confirmada'
        AND r.data_chegada < data_saida_desejada  
        AND r.data_saida > data_chegada_desejada; 

END $$;

-- Exibe o resultado final, ordenado por quarto
SELECT * FROM ResultadoDisponibilidade
ORDER BY numero_do_quarto, cama;
