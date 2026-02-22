#📦 Webshop Database Lab – PostgreSQL

Este repositório documenta a configuração completa de um banco de dados relacional para um sistema de e-commerce fictício utilizando PostgreSQL.

O objetivo é construir, passo a passo, um ambiente realista para prática de SQL e administração básica de banco de dados, incluindo criação de tipos, tabelas, relacionamentos e inserção de dados com lógica procedural. Não é necessário subir Vms, pode utilizar sendo localhost, apenas basta instalar o postgreSQL e ter o vscode para possíveis mudanças nos códigos de configuração;


🧱 O que está sendo configurado

    Neste projeto configuramos:
-Um database dedicado para o laboratório
-Um schema chamado webshop
-Tipos ENUM
-Tabelas com múltiplas FOREIGN KEYS
-Relacionamentos 1:N e N:1
-Dependências encadeadas entre entidades
-Geração de dados com TEMP TABLE
-Inserções em massa utilizando DO $$ (PL/pgSQL)

