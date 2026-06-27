# Frontend — Clínica Odontológica (React + Create React App)

Interface web feita com **React** (usando **Create React App** / `react-scripts`,
o mesmo ambiente usado nas aulas) em **JavaScript puro** (sem TypeScript).
Consome a API do backend em `http://localhost:8080/api`.

> O código é simples e está comentado em português, usando só `useState` e
> `useEffect` (sem Redux nem Context API), para ficar fácil de entender e dar
> manutenção depois.

## Tecnologias

- React 18
- Create React App (`react-scripts`) — mesmo ambiente das aulas
- react-router-dom 6 (navegação entre as telas)
- CSS simples (arquivo `src/index.css`)

## Pré-requisitos

- **Node.js 18+** instalado (`node -v` para conferir).
- O **backend rodando** em `http://localhost:8080` (senão as telas mostram erro de conexão).

## Como rodar

Dentro da pasta `/frontend`, execute:

```bash
npm install      # baixa as dependências (só precisa na primeira vez)
npm start        # inicia o servidor de desenvolvimento
```

O navegador abre sozinho no endereço:

```
http://localhost:5173
```

> O Create React App usa a porta `3000` por padrão. Aqui mudamos para `5173`
> no arquivo `.env` (linha `PORT=5173`), que é a porta liberada pelo backend no
> CORS. Para usar outra porta, é só trocar esse número no `.env`.

## Telas disponíveis (menu no topo)

- **Início** — painel com os números da clínica e os próximos agendamentos.
- **Planos** — cadastrar e listar planos odontológicos (definem o desconto).
- **Pacientes** — cadastrar, **editar** e listar pacientes, com **busca por nome ou CPF** (no editar dá para, por exemplo, colocar o paciente em um plano).
- **Dentistas** — cadastrar e listar dentistas.
- **Procedimentos** — cadastrar e listar procedimentos (serviços e valores).
- **Agendamentos** — formulário com **dropdowns** de paciente, dentista e procedimento, e **mudança de status** na lista (Agendado, Cancelado, Remarcado, Paciente Faltou, Atendimento Concluído).
- **Consultas** — registrar a consulta (o **valor total é calculado** com o desconto do plano).
- **Histórico** — registrar histórico clínico **vinculado a um paciente**.
- **Pagamentos** — registrar pagamento **vinculado a uma consulta**.

## Tratamento de erros

Quando o backend retorna um erro (ex: CPF já cadastrado, horário ocupado, valor inválido),
a tela mostra a mensagem em uma **faixa vermelha** no topo do formulário. Quando dá certo,
mostra uma **faixa verde** de sucesso. Isso é feito com `useState` (`erro` e `sucesso`)
em cada tela.

## Estrutura de pastas

```
frontend/
├── package.json            # dependências e scripts (start, build, test)
├── public/
│   └── index.html          # página base onde o React é montado
└── src/
    ├── index.js            # ponto de entrada (liga o React e o roteador)
    ├── reportWebVitals.js  # medição opcional de performance (vem do Create React App)
    ├── App.js              # menu + definição das rotas (telas)
    ├── api.js              # TODAS as chamadas à API ficam centralizadas aqui
    ├── index.css           # estilos simples (nav, formulários, tabelas, mensagens)
    └── pages/              # uma tela por arquivo
        ├── Home.js
        ├── Planos.js
        ├── Pacientes.js
        ├── Dentistas.js
        ├── Procedimentos.js
        ├── Agendamentos.js
        ├── Consultas.js
        ├── HistoricoClinico.js
        └── Pagamentos.js
```

## Exemplo de fluxo completo (do cadastro ao pagamento)

1. Cadastre um **Plano** (ex: 20% de desconto).
2. Cadastre um **Paciente** e vincule esse plano.
3. Cadastre um **Dentista** e um **Procedimento** (ex: R$ 150,00).
4. Crie um **Agendamento** juntando os três.
5. Registre a **Consulta** desse agendamento → o valor sai **R$ 120,00** (150 − 20%).
6. Registre o **Pagamento** dessa consulta.
