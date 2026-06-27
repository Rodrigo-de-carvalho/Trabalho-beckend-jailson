-- ============================================================
--  ATUALIZAÇÃO DO BANCO — adiciona o status "Atendimento Concluído"
-- ============================================================
-- Quando rodar: SE você já criou o banco antes com o schema.sql ANTIGO
-- (que tinha só 4 status no agendamento), rode este script UMA vez para
-- adicionar o novo status "Atendimento Concluído".
--
-- Se você for criar o banco do zero com o schema.sql atual, NÃO precisa
-- rodar este arquivo (o schema.sql já vem com os 5 status).
--
-- Como rodar (terminal):
--   mysql -u root -p < atualizacao-status-agendamento.sql
-- Ou abra no MySQL Workbench e clique no raio (⚡).

USE clinica_odontologica;

-- MODIFY troca a definição da coluna "status" para incluir o novo valor,
-- sem apagar nenhum agendamento que já existe.
ALTER TABLE agendamento
    MODIFY status ENUM('Agendado', 'Cancelado', 'Remarcado', 'Paciente Faltou', 'Atendimento Concluído') DEFAULT 'Agendado';
