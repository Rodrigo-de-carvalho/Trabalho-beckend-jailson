# 🦷 Sistema de Gestão — Clínica Odontológica

Trabalho de faculdade completo, dividido em **3 camadas** que se comunicam:

| Pasta | O que é | Tecnologia |
|-------|---------|------------|
| [`/banco-de-dados`](./banco-de-dados) | Script do banco de dados (9 tabelas) | MySQL |
| [`/backend`](./backend) | API REST (regras de negócio) | Java + Spring Boot |
| [`/frontend`](./frontend) | Telas web para o usuário | React (Create React App) |

O fluxo é: o **frontend** (telas) chama o **backend** (API), que lê e grava no **banco de dados**.

> 📓 As **[NOTAS do projeto](./NOTAS.md)** têm o resumo da arquitetura, o que cada
> camada do backend faz, o significado das anotações (`@Entity`, `@ManyToOne`...) e o
> passo a passo para rodar tudo na ordem certa.

```
[ React (CRA) ]   --HTTP/JSON-->  [ Spring Boot API ]  --JPA/SQL-->  [ MySQL ]
   localhost:5173                     localhost:8080                  localhost:3306
```

---

## ▶️ Ordem de execução (como rodar o projeto)

Siga **exatamente nesta ordem**. Cada parte depende da anterior estar funcionando.

### 1º) Banco de dados (MySQL)

Pasta: [`/banco-de-dados`](./banco-de-dados)

- Abra o **MySQL Workbench** (ou o terminal) e rode o arquivo `schema.sql`.
- Isso cria o banco `clinica_odontologica` com as **9 tabelas**.
- Confira com `SHOW TABLES;` (devem aparecer 9 tabelas).

> Detalhes no [README do banco](./banco-de-dados/README.md).

### 2º) Backend (Spring Boot)

Pasta: [`/backend`](./backend)

- **Ajuste o usuário/senha do MySQL** em `src/main/resources/application.properties`
  (padrão: usuário `root`, senha vazia).
- Rode:

  ```bash
  mvn spring-boot:run
  ```

- A API sobe em `http://localhost:8080`.

> Detalhes e lista de endpoints no [README do backend](./backend/README.md).

### 3º) Frontend (React)

Pasta: [`/frontend`](./frontend)

- Rode:

  ```bash
  npm install
  npm start
  ```

- O navegador abre sozinho em `http://localhost:5173` (porta definida no `frontend/.env`).

> Detalhes no [README do frontend](./frontend/README.md).

---

## ✅ Como testar se os 3 estão se comunicando

Esse é o teste que prova que **banco + backend + frontend** estão integrados:

1. Com tudo rodando, abra o frontend em `http://localhost:5173`.
2. Vá no menu em **Pacientes**.
3. Preencha o formulário (nome, CPF, telefone) e clique em **Cadastrar paciente**.
4. Deve aparecer a mensagem verde **"Paciente cadastrado com sucesso!"** e o
   paciente surge na tabela logo abaixo.
5. **Confirme que chegou no banco de dados.** No MySQL Workbench (ou terminal), rode:

   ```sql
   USE clinica_odontologica;
   SELECT * FROM paciente;
   ```

   O paciente que você cadastrou pela tela deve aparecer na tabela. 🎉

Se ele aparecer no banco, está provado que:
- o **frontend** enviou os dados para o **backend** (HTTP/JSON);
- o **backend** aplicou as regras e gravou no **banco** (JPA/SQL);
- os três estão conversando corretamente.

### Bônus: testar uma regra de negócio

Tente cadastrar **outro** paciente com o **mesmo CPF**. O sistema vai recusar e
mostrar uma faixa vermelha: **"Já existe um paciente cadastrado com este CPF."**
Isso é a validação de unicidade feita no backend (que retorna o status HTTP 409).

---

## 🧩 Regras de negócio implementadas no backend

- **CPF, e-mail e CRO únicos** — não deixa cadastrar duplicado (erro 409 com mensagem clara).
- **Horário do dentista** — não permite dois agendamentos no mesmo dentista na mesma data/hora.
- **Cálculo do valor da consulta** — o valor total é calculado automaticamente:
  `valor do procedimento − desconto do plano do paciente`.

---

## 📁 Estrutura geral do repositório

```
beckend/
├── README.md                 # este arquivo (visão geral + ordem de execução)
├── banco-de-dados/
│   ├── schema.sql            # cria o banco e as 9 tabelas
│   └── README.md
├── backend/
│   ├── pom.xml
│   ├── src/main/java/...     # Entity, Repository, Service, Controller, Exception
│   ├── src/main/resources/application.properties
│   └── README.md
└── frontend/
    ├── package.json
    ├── src/...               # api.js + telas (pages) em React
    └── README.md
```

---

## 💡 Observações

- O código do **backend** e do **frontend** está **comentado em português**, explicando
  o porquê de cada parte para facilitar o entendimento e a manutenção.
- O backend **não usa Lombok** de propósito (getters/setters escritos à mão deixam o
  código mais explícito e fácil de entender).
- As telas de **Planos** e **Consultas** foram incluídas (além das pedidas) porque o
  cadastro de paciente usa o plano e o pagamento depende da consulta — assim o sistema
  funciona de ponta a ponta.
