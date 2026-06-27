# Backend — Clínica Odontológica (Spring Boot + MySQL)

API REST feita com **Spring Boot 3** e **Maven**, organizada em camadas
(**Entity → Repository → Service → Controller**) e conectada ao banco MySQL
criado pelo `schema.sql` da pasta `/banco-de-dados`.

> Todo o código está comentado em português, explicando o que cada classe,
> método e anotação faz, para facilitar o entendimento e a manutenção.

## Tecnologias

- Java 17
- Spring Boot 3.2.5 (Web, Data JPA)
- MySQL 8 (driver `mysql-connector-j`)
- Maven (gerenciador de dependências e build)
- **Sem Lombok** (o código é explícito, com getters/setters escritos à mão)

## Pré-requisitos

1. **Java 17** instalado (`java -version` deve mostrar 17 ou superior).
2. **Maven** instalado (`mvn -version`).
3. **MySQL** rodando em `localhost:3306` com o banco já criado
   (rode antes o `schema.sql` da pasta `/banco-de-dados`).

## Passo importante: ajustar usuário e senha do MySQL

Abra o arquivo:

```
backend/src/main/resources/application.properties
```

E ajuste, se necessário, estas duas linhas para o seu MySQL:

```properties
spring.datasource.username=root
spring.datasource.password=
```

- O padrão é usuário `root` e **senha vazia**.
- Se o seu MySQL tiver senha, escreva-a depois do `=` (ex: `spring.datasource.password=minhasenha`).

## Como rodar

Dentro da pasta `/backend`, execute:

```bash
mvn spring-boot:run
```

Quando aparecer no console algo como `Started ClinicaOdontologicaApplication`,
a API estará no ar em:

```
http://localhost:8080
```

> A propriedade `spring.jpa.show-sql=true` faz o console mostrar o SQL que o
> Hibernate executa — útil para conferir as queries que estão rodando de verdade.

## CORS (integração com o frontend)

O backend já libera o endereço do React em desenvolvimento
(`http://localhost:5173`) na classe `config/CorsConfig.java`, então o frontend
consegue chamar a API sem erro de bloqueio do navegador. O Create React App
roda na porta 3000 por padrão, mas mudamos para 5173 no arquivo `frontend/.env`.

## Endpoints disponíveis

Todos começam com o prefixo `/api`. O padrão de CRUD é o mesmo para todas as entidades:

| Método | Caminho                  | O que faz                         |
|--------|--------------------------|-----------------------------------|
| GET    | `/api/{recurso}`         | Lista todos                       |
| GET    | `/api/{recurso}/{id}`    | Busca um pelo id                  |
| POST   | `/api/{recurso}`         | Cria um novo                      |
| PUT    | `/api/{recurso}/{id}`    | Atualiza um existente             |
| DELETE | `/api/{recurso}/{id}`    | Apaga um                          |

Recursos (`{recurso}`):

- `/api/planos` — planos odontológicos
- `/api/pacientes` — pacientes (+ busca: `GET /api/pacientes/buscar?termo=texto`)
- `/api/dentistas` — dentistas
- `/api/procedimentos` — procedimentos
- `/api/agendamentos` — agendamentos
- `/api/consultas` — consultas (valor total calculado automaticamente)
- `/api/pagamentos` — pagamentos
- `/api/historicos` — históricos clínicos (+ por paciente: `GET /api/historicos/paciente/{idPaciente}`)
- `/api/agendas` — agendas/horários (+ por dentista: `GET /api/agendas/dentista/{idDentista}`)

### Exemplos de uso (curl)

**1. Cadastrar um plano:**

```bash
curl -X POST http://localhost:8080/api/planos \
  -H "Content-Type: application/json" \
  -d '{"nomePlano":"Plano Sorriso","operadora":"OdontoPrev","descontoPercentual":20.00,"cobertura":"Limpeza, restauração e canal"}'
```

**2. Cadastrar um paciente (com plano de id 1):**

```bash
curl -X POST http://localhost:8080/api/pacientes \
  -H "Content-Type: application/json" \
  -d '{"nomeCompleto":"Maria Silva","cpf":"12345678901","telefone":"11999998888","email":"maria@email.com","sexo":"Feminino","plano":{"idPlano":1}}'
```

> Sem plano? É só não enviar o campo `plano` (ou enviar `"plano": null`).

**3. Tentar cadastrar OUTRO paciente com o mesmo CPF (erro 409):**

```bash
curl -X POST http://localhost:8080/api/pacientes \
  -H "Content-Type: application/json" \
  -d '{"nomeCompleto":"Outra Pessoa","cpf":"12345678901","telefone":"11000000000"}'
```

Resposta (status HTTP 409):

```json
{
  "mensagem": "Já existe um paciente cadastrado com este CPF."
}
```

> O código HTTP (409) vem no cabeçalho da resposta; o corpo traz só a mensagem clara.

**4. Cadastrar um dentista:**

```bash
curl -X POST http://localhost:8080/api/dentistas \
  -H "Content-Type: application/json" \
  -d '{"nomeCompleto":"Dr. João Souza","cro":"CRO-SP-12345","especialidade":"Ortodontia","telefone":"11988887777","email":"joao@clinica.com"}'
```

**5. Cadastrar um procedimento:**

```bash
curl -X POST http://localhost:8080/api/procedimentos \
  -H "Content-Type: application/json" \
  -d '{"nome":"Limpeza","descricao":"Limpeza e profilaxia","valor":150.00,"tempoEstimado":40}'
```

**6. Criar um agendamento (paciente 1, dentista 1, procedimento 1):**

```bash
curl -X POST http://localhost:8080/api/agendamentos \
  -H "Content-Type: application/json" \
  -d '{"paciente":{"idPaciente":1},"dentista":{"idDentista":1},"procedimento":{"idProcedimento":1},"dataHora":"2026-07-01T09:00:00","status":"Agendado"}'
```

**7. Registrar a consulta (a partir do agendamento 1) — o valor é calculado sozinho:**

```bash
curl -X POST http://localhost:8080/api/consultas \
  -H "Content-Type: application/json" \
  -d '{"agendamento":{"idAgendamento":1},"dataHoraRealizacao":"2026-07-01T09:00:00","observacoes":"Tudo certo"}'
```

> Se o procedimento custa R$ 150,00 e o plano do paciente dá 20% de desconto,
> o `valorTotal` retornado será `120.00`.

**8. Registrar o pagamento da consulta 1:**

```bash
curl -X POST http://localhost:8080/api/pagamentos \
  -H "Content-Type: application/json" \
  -d '{"consulta":{"idConsulta":1},"formaPagamento":"Pix","valorPago":120.00,"parcelas":1}'
```

**9. Registrar histórico clínico do paciente 1:**

```bash
curl -X POST http://localhost:8080/api/historicos \
  -H "Content-Type: application/json" \
  -d '{"paciente":{"idPaciente":1},"alergias":"Penicilina","doencasSistemicas":"Nenhuma","medicamentosContinuos":"Nenhum"}'
```

**10. Listar todos os pacientes / buscar por nome ou CPF:**

```bash
curl http://localhost:8080/api/pacientes
curl "http://localhost:8080/api/pacientes/buscar?termo=Maria"
```

## Tratamento de erros

Toda a aplicação usa um **tratador global de erros** (`GlobalExceptionHandler`)
que devolve um JSON claro com o status HTTP correto:

- **400 Bad Request** — dados inválidos (ex: valor pago negativo, campo obrigatório faltando).
- **404 Not Found** — registro não encontrado (ex: buscar um id que não existe).
- **409 Conflict** — conflito de dados (ex: CPF/CRO/e-mail duplicado, horário ocupado).

## Estrutura de pastas

```
backend/
├── pom.xml                         # dependências e configuração do Maven
├── src/main/resources/
│   └── application.properties      # configuração do banco (ajustar usuário/senha aqui)
└── src/main/java/com/clinica/odontologica/
    ├── ClinicaOdontologicaApplication.java   # classe principal (main)
    ├── config/CorsConfig.java                # libera o frontend (CORS)
    ├── entity/        # as 9 entidades JPA (espelham as tabelas)
    ├── repository/    # acesso ao banco (JpaRepository)
    ├── service/       # regras de negócio (validações e cálculos)
    ├── controller/    # endpoints REST (/api/...)
    └── exception/     # exceções e tratador global de erros
```
