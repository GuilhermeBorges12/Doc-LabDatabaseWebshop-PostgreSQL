-- =========================================
		CONSULTAS SQL - WEBSHOP
-- =========================================

		--CONSULTAS BÁSICAS 
--1
SELECT firstname,lastname,email
FROM CUSTOMER;

--2
SELECT *
FROM products
ORDER BY created DESC
LIMIT 10;

--3
SELECT name,currentlyactive
FROM products
WHERE currentlyactive = true;

--4
SELECT *
FROM articles;
WHERE CAST(originalprice AS numeric)> 100;

--5
SELECT *
FROM articles A
WHERE discountinpercent > 30;

--6 selecionando todos os clientes que começam com a letra A 

SELECT c.firstname 
FROM customer c
WHERE c.firstname LIKE '%A%';

--7 Todos os pedidos feitos após uma determinada DATA
SELECT ordertimestamp 
FROM "order" 
WHERE ordertimestamp > '2025-10-1';

--8 listando preço entre dois valores definidos
SELECT  a.description , a.originalprice
FROM  articles  a
WHERE originalprice BETWEEN '64,00' AND '131,00';

=========================================
       CONSULTAS INTERMEDIÁRIO
=========================================

--9 Listando todos os pedidos com nome do cliente
SELECT c.id , o.customerid, c.firstname
FROM "order" o 
INNER JOIN customer c ON c.id = o.customerid;

--10 listando os produtos comprados em cada pedido (VOLTAR NESSA)
SELECT a.productid , p.id, p.name
from articles a
INNER JOIN  products p ON a.productid = p.id; 

--11 mostrando todos os clientes e os repectivos pedidos, inclusive os que não fizeram pedido(utilizei left join)
SELECT c.firstname, o.id , c.id
FROM customer c
LEFT JOIN "order" o ON c.id = o.id;

--12 listando pedidos contendo : nome_cliente, nome do produto, quantidade/ligar customer -> order -> order_positions -> articles -> products
SELECT c.firstname AS PRIMEIRO_NOME , p.name AS PRODUTO, op.amount AS QUANTIA
FROM CUSTOMER c
INNER JOIN "order" o ON c.id = o.customerid
INNER JOIN ORDER_POSITIONS op ON  o.id = op.orderid
INNER JOIN ARTICLES a ON op.articleid = a.id
INNER JOIN PRODUCTS p ON a.productid = p.id
ORDER BY c.firstname ASC;

--13  todos os artigos com nome do produto , cor e tamanho
SELECT p.name AS NOME_DO_PRODUTO , co.rgb AS COR_DO_PRODUTO , s.size AS TAMANHO
FROM PRODUCTS p 
INNER JOIN ARTICLES a ON p.id = a.productid
INNER JOIN COLORS  co ON a.colorid = co.id
INNER JOIN SIZES s ON a.sizeid = s.id

--14 listando os clientes e o total de pedido por cada uma
SELECT 
    c.id,
    c.firstname,
    c.lastname,
    COUNT(o.id) AS total_pedidos
FROM webshop.customer c
LEFT JOIN webshop."order" o 
    ON c.id = o.customerid
GROUP BY c.id, c.firstname, c.lastname
ORDER BY total_pedidos DESC;

--15  O produto que nunca  foi vendido
SELECT DISTINCT p.id, p.name
FROM products p
LEFT JOIN webshop.articles a 
    ON p.id = a.productid
LEFT JOIN order_positions op 
    ON a.id = op.articleid
WHERE op.id IS NULL;

--16 Faturamento total da loja 
SELECT 
    SUM(op.amount * op.price) AS faturamento_total
FROM webshop.order_positions op;

--17 Faturamento por produto(incluindo os que nunca foram vendidos)
SELECT 
    p.name AS nome_item,
    SUM(op.amount * op.price) AS faturamento_item
FROM products p
LEFT JOIN articles a
    ON p.id = a.productid
LEFT JOIN order_positions op
    ON a.id = op.articleid
GROUP BY p.name
ORDER BY faturamento_item DESC;

--18 Calculando total por clientes (inclusive os que nunca compraram)
SELECT 
	c.firstname AS NOME,
	SUM(op.amount * op.price) AS TOTAL
FROM CUSTOMER c
LEFT JOIN "order" o
	ON c.id = o.customerid
LEFT JOIN order_positions op
	ON o.id = op.orderid
GROUP BY c.firstname
ORDER BY c.firstname ASC;

--19 Descubra o ticket médio (valor médio por pedido).
SELECT
	SUM(op.amount * op.price) / COUNT(DISTINCT op.id)
FROM order_positions op;


=========================================
		CONSULTAS AVANÇADAS
=========================================

--20 Mostre o produto mais vendido (por quantidade).
SELECT 
    p.name AS produto,
    SUM(op.amount) AS quantidade_vendida
FROM products p
JOIN articles a
    ON p.id = a.productid
JOIN order_positions op
    ON a.id = op.articleid
GROUP BY p.name
ORDER BY quantidade_vendida DESC
LIMIT 1;

--21 Mostre o produto que mais gerou receita.
SELECT 
    p.name AS produto,
    SUM(op.amount*op.price) AS quantidade_vendida
FROM products p
JOIN articles a
    ON p.id = a.productid
JOIN order_positions op
    ON a.id = op.articleid
GROUP BY p.name
ORDER BY quantidade_vendida DESC
LIMIT 1;

--22 Liste clientes que fizeram mais de 3 pedidos
SELECT --clientes que realizaram mais de tres pedidos
 	c.firstname AS nome_cliente,
	 SUM(op.amount) AS qtd_pedido -- somando as qtd de pedidos 
FROM CUSTOMER c
JOIN "order" o
	ON c.id = o.customerid
JOIN order_positions op
	ON o.id = op.orderid
GROUP BY c.firstname
HAVING SUM(op.amount) > 3
ORDER BY qtd_pedido DESC;

--23 Calculando o faturamento por mês
SELECT 
    DATE_TRUNC('month', o.ordertimestamp) AS mes, --date_trunc converte o formato de timestamp para : 2024/11/01
    SUM(op.amount * op.price) AS faturamento --conta simples de faturamento quantia * preço
FROM "order" o
JOIN order_positions op
    ON o.id = op.orderid
GROUP BY mes --agrupando pelos meses
ORDER BY mes; 

--24 Descubra o maior pedido já realizado (maior valor total).
SELECT 
	SUM(op.amount * op.price) AS valor, --valor
	p.name AS nome_produto
FROM order_positions op
JOIN articles a
	ON op.articleid = a.id
JOIN products p
	ON a.productid = p.id
GROUP BY  nome_produto
ORDER BY  valor DESC --aqui meio ordeno do maior pro menor(decrescente)
LIMIT 1 ; -- aqui eu utilizo o limit como se fosse um filtro WHERE, já que limito apenas o primeiro item que é o maior

--25 Listei os 3 produtos mais vendidos por mês.
SELECT *
FROM (
    SELECT 
        DATE_TRUNC('month', o.ordertimestamp) AS mes,
        p.name AS produto,
        SUM(op.amount) AS quantidade_vendida,
        ROW_NUMBER() OVER (             --utilizei window function para trabalhar e filtrar uma parte especifica dos dados, nesse caso o row_number cria um fake rank
            PARTITION BY DATE_TRUNC('month', o.ordertimestamp) --dividindo por mês, quero todos os top 3 item de janeiro, depois dez, etc 
            ORDER BY SUM(op.amount) DESC
        ) AS ranking 
    FROM "order" o
    JOIN order_positions op
        ON o.id = op.orderid
    JOIN articles a
        ON op.articleid = a.id
    JOIN products p
        ON a.productid = p.id
    GROUP BY mes, p.name
) ranking_produtos -- subquerie 
WHERE ranking <= 3 --filtrei só o top 3, poderia usar o limit 3 também
ORDER BY mes, ranking; -- ordernei por mês , ou seja, vai vir tudo de janeiro, depois tudo em fevereiro, assim em diante. depois ordenei por ranking (top 1 - 2 - 3)


--26 gerando ranking  de clientes por valor total gasto
--para gerar um raking de cliente vou ter que utilizar row_number (para conseguir classificar/criar rank em números), vou ter que achar o valor total por cliente
SELECT --na criação dessa query, me deparei com um erro, tentei utilizar sem subquerie,porém o WHERE processa antes do calculo, então a saída foi ter que usar  subquerie para primeiro calcular e classificar para depois filtrar
    cliente,
    ranking,
	total
FROM (
    SELECT
        c.firstname AS cliente, --nome clientes
        SUM(op.amount * op.price) AS total, --valor total gasto
        ROW_NUMBER() OVER(ORDER BY SUM(op.amount * op.price) DESC) AS ranking --criando ranking com window function e ordenando por ordem decrescente
    FROM
        customer c
    INNER JOIN
        "order" o ON c.id = o.customerid
    INNER JOIN
        order_positions op ON o.id = op.orderid
    GROUP BY
        c.id, c.firstname
) AS subquery
ORDER BY
    ranking;
	


--27 Calcule o percentual de participação de cada produto no faturamento total.
--A lógica é achar o total de faturamento, e converter em porcentual a participação daquele produto, ou seja dividir total/produto
-- tabelas  order_positions , articles, products 
SELECT 
    p.name AS produto,
    SUM(op.amount * op.price) AS faturamento_produto,
    
        (SUM(op.amount * op.price) * 100.0) --TOTAL PRODUTO
        / SUM(SUM(op.amount * op.price)) OVER () AS percentual_participacao --TOTAL GERAL , SOMA AGREGAÇÃO	
FROM products p
JOIN articles a
    ON p.id = a.productid
JOIN order_positions op
    ON a.id = op.articleid
GROUP BY p.name
ORDER BY percentual_participacao DESC;


--28 Descubra o maior pedido já feito (valor total).
SELECT 
	o.id,
	p.name,
	MAX(o.total)
FROM "order" o  
INNER JOIN order_positions op
 	ON o.id = op.orderid
INNER JOIN articles a 
	ON a.id = op.articleid
INNER JOIN products p 
	ON a.productid = p.id
GROUP BY o.id, p.name
ORDER BY o.total DESC;


--29 Calculando a taxa de recompra (clientes com mais de 1 pedido).
SELECT 
	c.firstname ||' '|| c.lastname  AS nome_cliente,
	COUNT(o.id) AS pedido
	
FROM customer c
INNER JOIN "order" o
	ON c.id = o.customerid
GROUP BY nome_cliente
HAVING COUNT (o.id) >1
ORDER BY pedido DESC;

--Tentei assim mas não entrega um valor %, ai fiz de outra forma.

WITH clientes_pedidos AS (
    SELECT 
        c.id,
        COUNT(o.id) AS qtd_pedidos
    FROM customer c
    LEFT JOIN "order" o
        ON c.id = o.customerid
    GROUP BY c.id
) -- aqui calculei a qtd de pedidos por cliente 
-- taxa de recompra por clientes é :  (clientes que compraram > 1 vez / total de clientes únicos) * 100
SELECT 
    ROUND(
        (COUNT(*) FILTER (WHERE qtd_pedidos > 1) * 100.0) 
        / COUNT(*),
        2
    ) AS taxa_recompra_percentual
FROM clientes_pedidos;


--30 calcular o percentual de clientes que nunca fizeram um pedido
WITH contando_clientes AS(
	SELECT 
		c.id, 
		COUNT (o.id) AS qtd_pedidos
	FROM customer c
LEFT JOIN "order" o 
	ON c.id = o.customerid	
GROUP BY c.id
)--contei todos clientes, inclusives os  sem pedidos com LEFT JOIN

SELECT 
	ROUND(
		COUNT(*) FILTER (WHERE qtd_pedidos = 0)*100.0/ COUNT(*),2) || '%' AS clientes_sem_pedidos  --Filtrei os que nunca fizeram e concatenei %
FROM contando_clientes


--31 Identifique clientes inativos (sem pedidos nos últimos 6 meses).
 --Encontrei a ultima compra utilizando (MAX), depois filtrei, os que nunca fizeram compra ou que não fazem compras faz 6 meses
WITH ultima_compra AS (
    SELECT 
        c.id,
        c.firstname,
        c.lastname,
        MAX(o.ordertimestamp) AS ultima_data
    FROM webshop.customer c
    LEFT JOIN webshop.order o
        ON c.id = o.customerid
    GROUP BY c.id, c.firstname, c.lastname
)

SELECT 
    firstname || ' ' || lastname AS nome_cliente,
    ultima_data
FROM ultima_compra
WHERE 
    ultima_data IS NULL
    OR ultima_data < NOW() - INTERVAL '6 months'
ORDER BY ultima_data;


--32  Receita perdida (produtos sem venda)
WITH produtos_sem_venda AS (
    SELECT 
        p.name,
        a.originalprice
    FROM webshop.products p
    JOIN webshop.articles a
        ON p.id = a.productid
    LEFT JOIN webshop.order_positions op
        ON a.id = op.articleid
    WHERE op.articleid IS NULL
)

SELECT 
    COUNT(*) AS total_itens_parados,
    SUM(originalprice) AS valor_total_parado,
    ROUND(AVG(originalprice), 2) AS preco_medio
FROM produtos_sem_venda;

