# 📦 Webshop Database Lab – PostgreSQL

Este repositório documenta a configuração completa de um banco de dados relacional para um sistema de e-commerce fictício utilizando **PostgreSQL**.
O objetivo é construir, passo a passo, um ambiente realista para prática de SQL e administração básica de banco de dados, incluindo criação de tipos, tabelas, relacionamentos e inserção de dados com lógica procedural.

Não é necessário utilizar máquinas virtuais. O ambiente pode ser configurado localmente (localhost) apenas com:

- PostgreSQL instalado  
- VS Code (opcional, para organização e edição dos scripts)

---

# 🧱 O que está sendo configurado

## 📁 Estrutura do Ambiente

- Um **database dedicado** para o laboratório  
- Um **schema chamado `webshop`**  
- Organização separada do schema padrão `public`  

---

## 🧬 Modelagem do Banco

- Tipos `ENUM`  
- Tabelas com múltiplas `FOREIGN KEYS`  
- Relacionamentos 1:N e N:1  
- Dependências encadeadas entre entidades  

---

## ⚙️ Inserção e Geração de Dados

- Uso de `TEMP TABLE`  
- Inserções em massa com `DO $$` (PL/pgSQL)  
- Controle de integridade referencial  

---

# 🏬 Estrutura Simulada (E-commerce)

O ambiente representa um sistema de loja virtual com as seguintes entidades:

- `customer`
- `address`
- `products`
- `articles`
- `"order"`
- `order_positions`
- `sizes`
- `labels`
- `colors`
# 📂 Estrutura do Projeto

A organização do repositório segue uma estrutura modular para facilitar manutenção, estudo e reutilização.


---

## 📁 data/

Diretório responsável pelos arquivos de carga de dados e massa de teste.

Pode conter:

- Scripts de `INSERT`
- Arquivos `.csv`
- Dados auxiliares para popular o banco
- Dumps parciais

---

## 📁 schema/

Contém toda a definição estrutural do banco de dados:

- Criação do database
- Criação do schema `webshop`
- Definição de ENUMs
- Criação de tabelas
- Constraints e Foreign Keys

Essa pasta representa a modelagem completa do banco.

---

## 📁 src/

Diretório destinado a scripts auxiliares e lógica procedural:

- Blocos `DO $$`
- Scripts de geração de dados
- Queries de teste
- Scripts analíticos

---

## 📜 dump

Script Shell responsável por gerar backup (dump) do banco de dados.

Permite exportar estrutura e/ou dados do laboratório.

---

## 📜 restore

Script Shell utilizado para restaurar o banco a partir de um dump previamente gerado.

Facilita a recriação completa do ambiente.

---

