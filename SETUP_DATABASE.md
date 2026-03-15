# Configuração do Banco de Dados Webshop (PostgreSQL)

Este guia mostra o **passo a passo para configurar manualmente o banco de dados Webshop** no PostgreSQL utilizando o **pgAdmin Query Tool**.

Durante essa configuração podem ocorrer alguns erros comuns relacionados a:

- Encoding
- Foreign Keys
- Ordem de criação de tabelas
- Schema não selecionado
- Execução de scripts grandes

Este tutorial também documenta **os principais problemas encontrados durante a configuração e como resolvê-los**.

---

# 1. Criando o Database

Abra o **Query Tool no pgAdmin** e execute:

```sql
CREATE DATABASE webshop;  --provavelmente vc vai estar na conexão default do postgreSQL, após executar o comando se conecte ao WEBSHOP.
```

```sql
--Para criar o schemma 
CREATE SCHEMA webshop;
```

Se quiser conferir rode esse comando e veja se aparece WEBSHOP:

```sql
SELECT schema_name 
FROM information_schema.schemata;
```

Defina o schemma padrão da sessão, porque mesmo que com o schemma criado o SGBD não encontra e puxa o schemma DEFAULT.

Utilize esse comando para resolver:

```sql
SET search_path TO webshop;
```

Isso vai fazer que vc possa escrever queries sem indicar de qual schemma elas pertencem.

---

# 2. Executando os Scripts SQL Automaticamente

Em vez de copiar e colar manualmente cada script no Query Tool, é possível utilizar o comando `\i` do PostgreSQL para executar arquivos `.sql` diretamente.

Isso torna o processo **mais rápido e reproduzível**.

No Query Tool ou no terminal `psql`, execute os scripts seguindo a ordem abaixo:

```sql
-- 1. Estrutura base
\i src/CREATE_TABLES.sql

-- 2. Tabelas de domínio
\i src/CREATE_SIZES.sql
\i src/CREATE_LABELS.sql

-- 3. Entidades principais
\i src/CREATE_CUSTOMERS.sql
\i src/CREATE_PRODUCTS.sql

-- 4. Relacionamentos
\i src/CREATE_STOCK.sql
\i src/CREATE_ORDERS.sql
\i src/CREATE_ADDRESS.sql
```

Essa ordem é importante porque algumas tabelas possuem depedências de foreign keys, tipo:

- Orders depende de Customer  
- Articles depende de Products  

Se a ordem não for respeitada, pode ocorrer o erro que eu tive na hora de configurar:

*violates foreign key constraint*

---

# Inserção de Dados com Lógica Procedural (PL/pgSQL)

Após a criação das tabelas, foi necessário popular o banco com dados para simular um ambiente real.

Para isso foram utilizados blocos de código **procedural do PostgreSQL (PL/pgSQL)** executados diretamente no **Query Tool**.

Esses blocos utilizam estruturas como:

- `DO $$`
- `DECLARE`
- `FOR LOOP`
- `WITH`
- `random()`

Eles permitem gerar **grandes volumes de dados automaticamente**, simulando:

- clientes
- produtos
- pedidos
- itens de pedido

---

# Exemplo de Inserção Procedural

Um exemplo utilizado foi a geração automática de produtos e artigos.

Esses blocos devem ser executados **inteiros**, pois contêm lógica procedural.

```sql
DO
$$
DECLARE
i record;
BEGIN
FOR i in 1..1000 LOOP

WITH label AS (
    SELECT id FROM webshop.labels ORDER BY random() LIMIT 1
),
color AS (
    SELECT id FROM webshop.colors ORDER BY random() LIMIT 1
),
product_insert AS (
    INSERT INTO webshop.products (name, labelid, category, gender, currentlyactive)
    SELECT 'Produto ' || random(), id, 'categoria', 'male', true
    FROM label
    RETURNING id
)

INSERT INTO webshop.articles (
    productid,
    ean,
    colorid,
    sizeid,
    description,
    originalprice,
    taxrate,
    currentlyactive
)
SELECT
    id,
    ceil(random() * 10 ^ 8),
    color.id,
    1,
    'Produto gerado automaticamente',
    100,
    19.0,
    true
FROM product_insert, color;

END LOOP;
END;
$$;
```

CASO O COMANDO NÃO SEJA EXECUTADO POR INTEIRO, PODE OCORRER ERROS COMO:

```
syntax error at or near DECLARE
```

Entre nos arquivos e veja que a lógica procedural foi utilizada mais para ficar simulando pedidos e artigos com nomes e itens diferentes.

---

Para conferir se a instalação funcionou corretamente e foi inserido os dados utilize o seguinte comando:

```sql
SELECT 'products' AS tabela, COUNT(*) FROM webshop.products
UNION ALL
SELECT 'articles', COUNT(*) FROM webshop.articles
UNION ALL
SELECT 'customers', COUNT(*) FROM webshop.customer
UNION ALL
SELECT 'orders', COUNT(*) FROM webshop.order
UNION ALL
SELECT 'order_positions', COUNT(*) FROM webshop.order_positions
UNION ALL
SELECT 'address', COUNT(*) FROM webshop.address;
```

Resultados esperados:

- Customer — 1000 linhas  
- Address — 1000 linhas  
- Order — 2000 linhas  
- Order_positions — 5985 linhas  
- Products — 1000 linhas  
- Articles — 16975 linhas  

---

# Problemas Encontrados Durante a Configuração

Durante a configuração do banco de dados **Webshop** alguns problemas que eu enfrentei.

Esta seção documenta os erros e as soluções aplicadas durante o processo.

Documentar esses problemas pode ajudar outras pessoas que estejam configurando o ambiente pela primeira vez.

---

## Problema com Inserção de Preços

Durante a geração automática de produtos e artigos houve um problema em que os **valores de preço não estavam sendo inseridos corretamente**.

Esse problema levou um tempo considerável para ser identificado durante o processo de configuração.

O script utilizava geração de valores aleatórios com múltiplas conversões de tipo:

```sql
ceil(random() * (150 - 50 + 1) + 50) :: text :: money
```

Essa cadeia de conversões pode gerar inconsistências dependendo da forma como o PostgreSQL interpreta o tipo `money`.

### Solução

Foi necessário revisar o script de geração de dados e garantir que os valores estivessem sendo inseridos corretamente nas colunas:

- `originalprice`
- `reducedprice`

Após o ajuste, os valores passaram a ser inseridos corretamente.

---

## Problema de Encoding (UTF-8)

Durante a execução de alguns scripts SQL foi encontrado um erro relacionado ao encoding dos arquivos.

Exemplo de erro:

```
invalid byte sequence for encoding "UTF8"
```

ou

```
character with byte sequence has no equivalent in UTF8
```

### Causa

Esse problema ocorre quando os arquivos `.sql` estão salvos em um encoding diferente do utilizado pelo banco de dados.

O PostgreSQL geralmente utiliza:

```
UTF8
```

Porém alguns arquivos podem estar salvos em formatos como:

- Windows-1252
- ISO-8859-1

Isso faz com que alguns caracteres especiais (`ç`, `ã`, `é`) não sejam interpretados corretamente.

### Solução

Converter os arquivos SQL para **UTF-8** antes de executá-los.

Exemplo no VS Code:

1. Abrir o arquivo `.sql`  
2. Clicar no encoding exibido no canto inferior direito  
3. Selecionar **Save with Encoding**  
4. Escolher **UTF-8**


