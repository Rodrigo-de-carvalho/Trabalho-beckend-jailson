# Notas do projeto — Clínica Odontológica

Minhas anotações sobre como o projeto funciona, pra lembrar de cada parte
quando for mexer nele de novo.

---

## A arquitetura, em poucas frases

O projeto tem **3 partes separadas**: a tela (frontend), as regras (backend) e
os dados (banco).

1. O **frontend** (React) são as páginas que o usuário vê e onde digita os dados.
2. O **backend** (Java + Spring Boot) recebe esses dados, aplica as regras
   (ex: não deixar CPF repetido) e decide o que salvar.
3. O **banco** (MySQL) é onde as informações ficam guardadas de verdade.

A conversa é em sequência: a tela fala com o backend por HTTP, e o backend fala
com o banco.

```
[ React (telas) ]  →  [ Spring Boot (regras) ]  →  [ MySQL (dados) ]
   porta 5173             porta 8080                porta 3306
```

---

## As camadas do backend (o que cada uma faz)

Separei o backend em camadas pra cada uma ter uma responsabilidade só. Se eu
precisar mudar uma regra, mexo só no Service e não bagunço o resto.

- **Entity (Entidade)** — classe Java que representa uma tabela do banco. Cada
  Entity (ex: `Paciente`) é uma tabela, e cada atributo é uma coluna. Serve pra
  eu trabalhar com objetos em vez de escrever SQL na mão.
- **Repository (Repositório)** — a parte que conversa direto com o banco (salvar,
  buscar, apagar). Só crio uma interface e o Spring entrega esses métodos prontos.
- **Service (Serviço)** — onde ficam as **regras de negócio**: validar se o CPF
  já existe, calcular o valor da consulta com desconto, etc. É a "inteligência".
- **Controller (Controlador)** — a porta de entrada da API. Recebe os pedidos da
  tela (criar, listar, atualizar, apagar) e devolve a resposta. Cada endereço
  tipo `/api/pacientes` cai num Controller.

---

## As anotações (os "@" no código)

- **`@Entity`** — avisa o Spring que aquela classe representa uma tabela do banco.
- **`@RestController`** — marca a classe como porta de entrada da API; o que ela
  devolve vira JSON automaticamente.
- **`@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`** — dizem qual
  tipo de pedido o método responde: `GET` lista/busca, `POST` cria, `PUT`
  atualiza, `DELETE` apaga.
- **`@ManyToOne`** — relacionamento "muitos para um". Ex: muitos pacientes podem
  ter um mesmo plano. É a chave estrangeira ligando uma tabela à outra.
- **Injeção de dependência (`@Autowired`)** — quando o Spring entrega sozinho um
  objeto que a classe precisa. No código eu faço isso **pelo construtor** (a
  classe pede no construtor e o Spring preenche). `@Autowired` faz o mesmo de
  outro jeito.

---

## Como as partes se comunicam

- **Frontend → backend:** por **HTTP** (os mesmos GET/POST do navegador). Os
  dados vão e voltam em **JSON** (texto organizado em "chave: valor").
- **Backend → banco:** o Java se conecta ao MySQL pelo driver **JDBC**, e por
  cima usamos o **Hibernate (JPA)**, que traduz os objetos Java em SQL sozinho —
  eu mando `salvar(paciente)` e ele gera o `INSERT`.
- **JPA / Hibernate**, em resumo: a ferramenta que faz a tradução entre objetos
  (Java) e tabelas/SQL (banco), pra eu não escrever SQL na mão a cada operação.
- Se o **backend não estiver rodando**, a tela abre mas não carrega nem salva
  nada — ela depende do backend pra tudo, e aparece erro de conexão.

---

## Como rodar (na ordem certa)

Cada parte depende da anterior. Deixo 2 terminais abertos.

### 1º) Banco (MySQL)
- Abrir o **MySQL Workbench** e rodar `banco-de-dados/schema.sql` (botão do raio ⚡).
- Conferir com `SHOW TABLES;` que aparecem as **9 tabelas**.

### 2º) Backend (Spring Boot)
- Conferir a senha do MySQL em `backend/src/main/resources/application.properties`.
- No terminal, dentro de `backend`:
  ```bash
  mvn spring-boot:run
  ```
- Esperar aparecer **`Started ClinicaOdontologicaApplication`**. A API sobe em
  `http://localhost:8080`.

### 3º) Frontend (React)
- Em outro terminal, dentro de `frontend`:
  ```bash
  npm install   # só na primeira vez
  npm start
  ```
- O navegador abre sozinho em `http://localhost:5173`.

---

## Fluxo completo pra testar de ponta a ponta

1. Tela **Início** mostra o painel com os números da clínica.
2. Em **Pacientes**, preencher nome, CPF e telefone e clicar em **Cadastrar** →
   aparece a mensagem verde e o paciente surge na tabela.
3. Conferir que gravou no banco mesmo, no MySQL Workbench:
   ```sql
   USE clinica_odontologica;
   SELECT * FROM paciente;
   ```
   O paciente digitado na tela aparece no banco — prova que as 3 partes estão
   integradas (a tela mandou, o backend validou e gravou, o banco guardou).
4. Regra de unicidade: tentar cadastrar outro paciente com o **mesmo CPF** → o
   sistema recusa com *"Já existe um paciente cadastrado com este CPF."* (HTTP 409).

> Pra ver o cálculo de valor: cadastrar antes um **Plano** (com desconto) e um
> **Procedimento** (com valor), fazer um **Agendamento** → **Consulta**, e o
> valor da consulta sai já com o desconto do plano aplicado.

---

## Regra de negócio mais importante

O **valor total da consulta é calculado automaticamente** (em `ConsultaService`):
pega o valor do procedimento e aplica o desconto do plano odontológico do
paciente, se ele tiver um. A consulta é criada a partir de um **agendamento**,
então paciente, dentista e procedimento vêm direto do que foi marcado — assim os
dados ficam sempre consistentes.
