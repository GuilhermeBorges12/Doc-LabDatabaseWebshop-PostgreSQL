CREATE TEMP TABLE names (
  name TEXT
);

INSERT INTO names
VALUES ('Feivel'), ('Buck'), ('Donner'), ('Durrant'), ('Eiko'), ('Beppo'), ('Gorre'), ('Alvaro'), ('Cucio'), ('Obin'),
  ('Hexana'), ('Dunja'), ('Ankana'), ('Elfy'), ('Iola'), ('Yoko'), ('Yesika'), ('Madame'), ('Marisa'), ('Anita'),
  ('Yambi'), ('Yla'), ('Ena'), ('Enne'), ('Herka'), ('Adria'), ('Ayleen'), ('Eddil'), ('Heifi'), ('Nady'), ('Fabian'),
  ('Flavko'), ('Nenno'), ('Dian'), ('Dreff'), ('Muneca'), ('Atlan'), ('Bast'), ('Gabor'), ('Hagar'), ('Dini'),
  ('Nanuc'), ('Chrisie'), ('Nadia'), ('Fluse'), ('Panka'), ('Camen'), ('Lolo'), ('Binda'), ('Bienchen'), ('Amin'),
  ('Arano'), ('Escudo'), ('Dexel'), ('Astrix'), ('Trick'), ('Herry'), ('Drenk'), ('Boogy'), ('Nanzo'), ('Eljin'),
  ('Broker'), ('Cylias'), ('Pepper'), ('Kiff'), ('Lumo'), ('Isto'), ('Andiamo'), ('Corsar'), ('Cimbo'), ('Floni'),
  ('Askania'), ('Aikita'), ('Arnhild'), ('Betzy'), ('Tura'), ('Jeana'), ('Laidy'), ('Guni'), ('Fabulous');

DROP TABLE categories;
CREATE TEMP TABLE categories(
  category category,
  product_type TEXT
);

INSERT INTO categories
    VALUES
      ('Apparel', 'T-Shirt'),
      ('Apparel', 'Blazer'),
      ('Apparel', 'Button-Down Shirt'),
      ('Apparel', 'Coat'),
      ('Apparel', 'Jacket'),
      ('Apparel', 'Dress Shirt'),
      ('Apparel', 'Hoodie'),
      ('Apparel', 'Sweatshirt'),
      ('Apparel', 'Jeans'),
      ('Apparel', 'Pajamas'),
      ('Apparel', 'Sleepwear'),
      ('Apparel', 'Pants'),
      ('Apparel', 'Polo'),
      ('Apparel', 'Shorts'),
      ('Apparel', 'Suit'),
      ('Apparel', 'Sweater'),
      ('Apparel', 'Swimwear'),
      ('Apparel', 'Boxer'),
      ('Apparel', 'Undershirt'),
      ('Apparel', 'Socks'),
      ('Apparel', 'Bra'),
      ('Apparel', 'Panty'),
      ('Apparel', 'Lingerie'),
      ('Apparel', 'Dress'),
      ('Apparel', 'Jumpsuit'),
      ('Apparel', 'Capris'),
      ('Apparel', 'Shorts'),
      ('Apparel', 'Skirt'),
      ('Apparel', 'Suit'),
      ('Apparel', 'Top'),
      ('Footwear', 'Athletic Shoes'),
      ('Footwear', 'Boots'),
      ('Footwear', 'Casual Shoes'),
      ('Footwear', 'Dress Shoes'),
      ('Footwear', 'Sandals'),
      ('Footwear', 'Flip-Flops'),
      ('Footwear', 'Sneakers'),
      ('Footwear', 'Booties'),
      ('Footwear', 'Comfort Shoes'),
      ('Footwear', 'Espadrilles'),
      ('Footwear', 'Flats'),
      ('Footwear', 'Heels'),
      ('Footwear', 'Pumps'),
      ('Footwear', 'Slippers'),
      ('Footwear', 'Wedges'),
      ('Footwear', 'Winter & Rain Boots'),
      ('Sportswear', 'Tracksuit'),
      ('Sportswear', 'Pants'),
      ('Sportswear', 'Jacket'),
      ('Sportswear', 'Underwear'),
      ('Sportswear', 'Hoodie'),
      ('Sportswear', 'Shirt'),
      ('Traditional', 'Costume'),
      ('Formal Wear', 'Suit'),
      ('Formal Wear', 'Dress'),
      ('Formal Wear', 'Tuxedo'),
      ('Accessories', 'Belt'),
      ('Accessories', 'Sunglasses'),
      ('Accessories', 'Scarf'),
      ('Accessories', 'Wrap'),
      ('Accessories', 'Wallet'),
      ('Watches & Jewelry', 'Watch'),
      ('Watches & Jewelry', 'Ring'),
      ('Watches & Jewelry', 'Necklace'),
      ('Watches & Jewelry', 'Bracelet'),
      ('Watches & Jewelry', 'Earring'),
      ('Watches & Jewelry', 'Cuffs'),
      ('Watches & Jewelry', 'Tie Clip'),
      ('Luggage', 'Backpack'),
      ('Luggage', 'Gym Bag'),
      ('Luggage', 'Laptop Bag'),
      ('Luggage', 'Carry-On'),
      ('Luggage', 'Suitcase'),
      ('Luggage', 'Garments Bag'),
      ('Cosmetics', 'Eye Makeup'),
      ('Cosmetics', 'Lipbalm'),
      ('Cosmetics', 'Nailpolish'),
      ('Cosmetics', 'Shampoo'),
      ('Cosmetics', 'Hair Gel')
;

DO
$$
DECLARE
i record;
BEGIN
FOR i in 1..1000 LOOP


WITH label AS (SELECT id FROM webshop.labels ORDER BY random() LIMIT 1),
    color AS (SELECT id FROM webshop.colors ORDER BY random() LIMIT (random() * 10 / 2) + 1),
    category_and_type AS (SELECT * FROM categories ORDER BY random() LIMIT 1),
    product_name AS (SELECT name FROM names ORDER BY random() LIMIT 1),
    fancy_name AS (SELECT product_type || ' ' || name AS name FROM category_and_type, product_name),
    gender AS (SELECT unnest :: gender as gender_name FROM (SELECT unnest(enum_range(NULL::gender))) as all_genders ORDER BY random() LIMIT 1),
    prices AS (SELECT
            (random() > 0.5)                                       as reduction,
            least(ceil(random() * 100 / 2) :: integer, 40)         as percentage,
            ceil(random() * (150 - 50 + 1) + 50) :: text :: money  as price),
    sizes AS (SELECT id FROM webshop.sizes, gender WHERE webshop.sizes.gender = gender.gender_name),
    product_insert as (INSERT INTO webshop.products (name, labelid, category, gender, currentlyactive)
                      (SELECT name, id, category, gender_name, true FROM fancy_name, label, category_and_type, gender)
                      RETURNING webshop.products.id as new_product_id)

INSERT INTO webshop.articles (productid, ean, colorid, sizeid, description, originalprice, reducedprice,
                              taxrate, discountinpercent, currentlyactive)
  (SELECT
     new_product_id,
     ceil(random() * 10 ^ 8) as ean,
     color.id,
     sizes.id,
     'The stylish ' || fancy_name.name || 'is just what you need right now!',
     prices.price,
     CASE WHEN prices.reduction
       THEN (prices.price * (1 - (prices.percentage :: DOUBLE PRECISION / 100)))
     ELSE null END,
     19.0 as taxrate,
     CASE WHEN prices.reduction
       THEN prices.percentage
     ELSE null END,
     true
   FROM product_insert, color, label, sizes, prices, fancy_name);

END LOOP;
END;
$$;


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'webshop'
  AND table_name = 'articles'
ORDER BY ordinal_position;

-- ver tabelas
\dt webshop.*

-- ver quantidade de dados
SELECT 'address', COUNT(*) FROM webshop.address
UNION ALL
SELECT 'customer', COUNT(*) FROM webshop.customer
UNION ALL
SELECT 'orders', COUNT(*) FROM webshop.orders
UNION ALL
SELECT 'articles', COUNT(*) FROM webshop.articles;

SELECT * FROM webshop.address;
SELECT * FROM webshop.customer;
SELECT * FROM webshop.stock;
select * from colors;
select * from webshop.order;
select * from products;


DO
$$
BEGIN
FOR i IN 1..2000 LOOP

WITH
    customer_cte AS (
        SELECT *
        FROM webshop.customer
        ORDER BY random()
        LIMIT 1
    ),

    article AS (
        SELECT a.id, a.reducedprice, a.originalprice
        FROM customer_cte c
        JOIN webshop.products p ON p.gender = c.gender
        JOIN webshop.articles a ON a.productid = p.id
        ORDER BY random()
        LIMIT (floor(random() * 10 / 2) + 1)
    ),

    order_ts AS (
        SELECT NOW() - random() * INTERVAL '2 years' AS ts
    ),

    total_sum AS (
        SELECT SUM(COALESCE(reducedprice, originalprice)) AS total
        FROM article
    ),

    order_insert AS (
        INSERT INTO webshop."order"
            (customerid, ordertimestamp, shippingaddressid, total, shippingcost)
        SELECT
            c.id,
            o.ts,
            c.currentaddressid,
            s.total,
            3.9
        FROM customer_cte c, order_ts o, total_sum s
        RETURNING id AS new_order_id
    )

    INSERT INTO webshop.order_positions (orderid, articleid, amount, price)
    SELECT
        oi.new_order_id,
        a.id,
        1,
        COALESCE(a.reducedprice, a.originalprice)
    FROM article a, order_insert oi;

END LOOP;
END;
$$;


SELECT
  (SELECT COUNT(*) FROM webshop.products)   AS products,
  (SELECT COUNT(*) FROM webshop.articles)   AS articles,
  (SELECT COUNT(*) FROM webshop.customer)   AS customers,
  (SELECT COUNT(*) FROM webshop."order")    AS orders,
  (SELECT COUNT(*) FROM webshop.order_positions) AS order_items;


  select * from webshop.stock;
  INSERT INTO webshop.stock (articleid, count) SELECT id, floor(random() * 10) FROM webshop.articles;



