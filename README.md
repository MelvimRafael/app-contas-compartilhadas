# Contas Compartilhadas

Contas Compartilhadas é um aplicativo desenvolvido em Flutter para gerenciar finanças coletivas em grupos, como famílias ou amigos que compartilham despesas. O frontend utiliza Flutter, enquanto o backend é desenvolvido com Django Rest Framework e Hasura GraphQL, proporcionando uma experiência completa de autenticação, gerenciamento de transações, e relatórios financeiros.

## Funcionalidades

- **Autenticação Segura**: Cadastro e login com suporte a tokens JWT.
- **Gerenciamento de Grupos**: Criação e gerenciamento de grupos de usuários.
- **Transações**: Cadastro de despesas e receitas, categorização e vinculação a grupos.
- **Relatórios e Gráficos**: Visualização de relatórios financeiros para cada grupo.
- **Limites de Grupos**: Contas Simples podem criar até 1 grupo, enquanto contas Premium podem criar até 5.
- **Interface Personalizada**: Tema azul com fonte personalizada, e suporte a dispositivos múltiplos usando `device_preview`.

## Tecnologias Utilizadas

### Frontend
- **Flutter**: Framework para construção de interfaces móveis multiplataforma.
- **Device Preview**: Utilizado para visualização e teste da aplicação em diferentes dispositivos.
- **Shared Preferences**: Para armazenamento de tokens JWT localmente.
- **Flutter Toast**: Para exibição de mensagens de sucesso e erro.

### Backend
- **Django Rest Framework (DRF)**: Fornece a API de autenticação e endpoints para usuários e grupos.
- **Hasura GraphQL**: Utilizado para manipulação de dados relacionados a transações e relatórios financeiros.
- **PostgreSQL**: Banco de dados utilizado para armazenar os dados da aplicação.
- **TokenAuthentication**: Utilizado para autenticação de usuários através de tokens.

## Endpoints da API

Abaixo estão alguns dos principais endpoints da API:

- **Cadastro (Signup)**:
  - `POST /api/auth/signup/`: Cria um novo usuário com os dados fornecidos e retorna um token de autenticação.
  
- **Login**:
  - `POST /api/auth/login/`: Autentica o usuário com base no nome de usuário e senha fornecidos, e retorna um token.

- **Logout**:
  - `GET /api/auth/logout/`: Remove o token de autenticação.

- **Grupos**:
  - `GET /api/groups/`: Retorna a lista de grupos do usuário logado.
  - `POST /api/groups/`: Cria um novo grupo.

- **Transações**:
  - `GET /api/transactions/`: Retorna a lista de transações.
  - `POST /api/transactions/`: Cria uma nova transação associada a um grupo.

## Estrutura de Dados

### Usuário
- `id`: Identificador do usuário.
- `username`: Nome de usuário.
- `first_name`: Primeiro nome.
- `last_name`: Sobrenome.
- `email`: Email do usuário.
- `renda`: Renda mensal fixa do usuário.
- `tipo`: Tipo de conta (Simples ou Premium).

### Grupo
- `id`: Identificador do grupo.
- `descricao`: Nome ou descrição do grupo.
- `dono`: Usuário que é dono do grupo.
- `membros`: Lista de membros do grupo.

### Transação
- `id`: Identificador da transação.
- `dono`: Usuário responsável pela transação.
- `valor`: Valor da transação.
- `data_pagamento`: Data de pagamento da transação.
- `grupo`: Grupo associado à transação.
- `tipo`: Tipo da transação (renda ou despesa).
- `descricao`: Descrição da transação.

## Instalação e Configuração

### Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:

- **Flutter**: [Instalar Flutter](https://flutter.dev/docs/get-started/install)
- **Python 3.x**: [Instalar Python](https://www.python.org/downloads/)
- **PostgreSQL**: [Instalar PostgreSQL](https://www.postgresql.org/download/)

### Passos para Configuração

1. Clone este repositório:
   ```bash
   git clone https://github.com/usuario/contas-compartilhadas.git
   cd contas-compartilhadas


flutter pub get
