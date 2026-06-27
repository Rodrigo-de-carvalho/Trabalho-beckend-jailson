# Banco de Dados — Clínica Odontológica

Esta pasta contém o script de criação do banco de dados MySQL usado pelo backend.

## Arquivo

- `schema.sql` — cria o banco `clinica_odontologica` e as **9 tabelas** do sistema:
  1. `plano_odontologico`
  2. `paciente`
  3. `dentista`
  4. `procedimento`
  5. `agendamento`
  6. `consulta`
  7. `pagamento`
  8. `historico_clinico`
  9. `agenda`

- `atualizacao-status-agendamento.sql` — script de atualização. Use **somente** se você
  já tinha criado o banco com uma versão antiga do `schema.sql` (que tinha só 4 status no
  agendamento). Ele adiciona o status **"Atendimento Concluído"** sem apagar dados.
  Quem cria o banco do zero com o `schema.sql` atual **não precisa** rodar este arquivo.

## Pré-requisitos

- **MySQL** instalado (recomendado MySQL 8.x).
- Opcionalmente o **MySQL Workbench** para uma interface visual.

## Como rodar o script

### Opção 1 — MySQL Workbench (interface visual)

1. Abra o **MySQL Workbench**.
2. Conecte na sua instância local (normalmente `localhost`, porta `3306`, usuário `root`).
3. Vá em **File > Open SQL Script...** e selecione o arquivo `schema.sql` desta pasta.
4. Clique no botão de **raio (Execute / ⚡)** para rodar o script inteiro.
5. Atualize a aba **Schemas** (ícone de refresh) — o banco `clinica_odontologica` deve aparecer na lista.

### Opção 2 — Terminal (linha de comando)

Dentro desta pasta (`/banco-de-dados`), rode:

```bash
mysql -u root -p < schema.sql
```

Digite a senha do MySQL quando for pedida (se o seu `root` não tiver senha, é só apertar Enter).

## Como confirmar que deu certo

Entre no MySQL e liste as tabelas:

```bash
mysql -u root -p
```

```sql
USE clinica_odontologica;
SHOW TABLES;
```

A saída deve listar exatamente as **9 tabelas**:

```
+----------------------------------+
| Tables_in_clinica_odontologica   |
+----------------------------------+
| agenda                           |
| agendamento                      |
| consulta                         |
| dentista                         |
| historico_clinico                |
| paciente                         |
| pagamento                        |
| plano_odontologico               |
| procedimento                     |
+----------------------------------+
9 rows in set
```

Se as 9 tabelas aparecerem, o banco foi criado com sucesso e o **backend** já pode se conectar a ele.

## Observações importantes

- O usuário/senha usados aqui precisam ser os **mesmos** configurados no backend, no arquivo
  `backend/src/main/resources/application.properties`.
- Se você precisar rodar o script de novo do zero, primeiro apague o banco antigo com:

  ```sql
  DROP DATABASE clinica_odontologica;
  ```

  e depois rode o `schema.sql` novamente.
