-- autors: xfedor14 (Tatiana Fedorova)
--         xramas01 (Jakub Ramašeuski)

-- Some attributes were slightly modified; quantity of individual goods was added as a parameter of the relationship
-- Otherwise, the solution complies with the requirements of Project 1

-- The project describes a relational database model for managing goods (fruits and vegetables), sales, deliveries
-- using entity relationships

-- Ignore errors related to DROP TABLE before the first use
DROP TABLE "Sold";
DROP TABLE "Located_At";
DROP TABLE "Sale" ;
DROP TABLE "Delivery";
DROP TABLE "Price_history";
DROP TABLE "Product";
DROP TABLE "Supplier";
DROP TABLE  "Branch";

DROP MATERIALIZED VIEW "branch_stock_mv";
DROP INDEX "sold_prod_idx";
DROP SEQUENCE "sale_seq";
DROP TRIGGER "sale_id_trigger";
DROP TRIGGER "sold_quantity_check";
DROP TRIGGER "update_stock_after_sold";
DROP PROCEDURE count_percent_of_sold_products;
DROP PROCEDURE report_product_locations;

---------------------------------------- CREATE TABLES ----------------------------------------

CREATE TABLE "Branch" (
    -- removed the type attribute
    "branch_id" INT GENERATED AS IDENTITY PRIMARY KEY,
    "branch_name" VARCHAR(255) NOT NULL,
    "address" VARCHAR(255) NOT NULL,
        -- only letters (upper/lower case), digits, spaces, apostrophes, commas and hyphens
        CHECK (REGEXP_LIKE("address", '^[a-zA-Z0-9\s,'' -]+$')),
    "phone_number" VARCHAR(20) NOT NULL
        -- format +123456789123
        CHECK (REGEXP_LIKE("phone_number", '^\+[0-9]{3}[0-9]{9}$'))
);

CREATE TABLE "Sale" (
    "sale_id" INT GENERATED AS IDENTITY PRIMARY KEY,
    "sale_date" DATE NOT NULL,
    "total_price" INT NOT NULL
        CHECK ( "total_price" > 0 ),
    "total_weight" INT NOT NULL
        CHECK ( "total_weight" > 0 ),
    "item_count" INT NOT NULL
        CHECK ( "item_count" > 0 ),
    "branch_id" INT NOT NULL,
        CONSTRAINT "sale_branch" FOREIGN KEY ("branch_id") REFERENCES "Branch" ("branch_id")
        ON DELETE CASCADE
);

CREATE TABLE "Product" (
    "product_id" INT GENERATED AS IDENTITY PRIMARY KEY,
    -- implemented via the type attribute since neither fruit nor vegetable entities have additional attributes
    "type" VARCHAR(10) NOT NULL,
        CONSTRAINT "product_type" CHECK ("type" IN ('fruit', 'vegetable') ),
    "product_name" VARCHAR(255) NOT NULL,
    "weight" INT NOT NULL
        CHECK ( "weight" > 0 ),
    "expiry_date" DATE NOT NULL,
    "selling_price" INT NOT NULL
        CHECK ( "selling_price" > 0 )
);

-- weak entity
CREATE TABLE "Price_history" (
    "product_id" INT NOT NULL,
    "price_date" DATE NOT NULL,
    "price" INT NOT NULL
        CHECK ( "price" > 0 ),
    CONSTRAINT "price_history_pk" PRIMARY KEY ("product_id", "price_date"),
    CONSTRAINT "price_history_product" FOREIGN KEY ("product_id") REFERENCES "Product" ("product_id")
        ON DELETE CASCADE
);

CREATE TABLE "Supplier" (
    "supplier_id" INT GENERATED AS IDENTITY PRIMARY KEY,
    "company_name" VARCHAR(255) NOT NULL,
    "address" VARCHAR(255) NOT NULL,
        -- only letters (upper/lower case), digits, spaces, apostrophes, commas and hyphens
        CHECK (REGEXP_LIKE("address", '^[a-zA-Z0-9\s,'' -]+$')),
    "phone_number" VARCHAR(20) NOT NULL,
        -- format +441234567890
        CHECK (REGEXP_LIKE("phone_number", '^\+[0-9]{3}[0-9]{9}$')),
    "email" VARCHAR(255) NOT NULL,
        -- format user@x.xx
        CHECK (REGEXP_LIKE("email", '^([a-zA-Z0-9]+[_.\-]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[.\-]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,}$'))
);

CREATE TABLE "Delivery" (
    "delivery_id" INT GENERATED AS IDENTITY PRIMARY KEY,
    "supplier_id" INT NOT NULL,
        CONSTRAINT  "delivery_supplier" FOREIGN KEY ("supplier_id") REFERENCES "Supplier" ("supplier_id")
        ON DELETE CASCADE,
    "delivery_date" DATE NOT NULL,
    "total_price" INT NOT NULL
        CHECK ( "total_price" > 0 ),
    "total_weight" INT NOT NULL
        CHECK ( "total_weight" > 0 ),
    "item_count" INT NOT NULL
        CHECK ( "item_count" > 0 )
);

-- added quantity of individual goods as a parameter of the relationship
CREATE TABLE "Sold" (
    "sale_id" INT NOT NULL,
    "product_id" INT NOT NULL,
    "quantity" INT NOT NULL
        CHECK ( "quantity" > 0 ),
        CONSTRAINT "sold_pk" PRIMARY KEY ("sale_id", "product_id"),
        CONSTRAINT "sold_sale" FOREIGN KEY ("sale_id") REFERENCES "Sale" ("sale_id")
        ON DELETE CASCADE,
        CONSTRAINT "sold_product" FOREIGN KEY ("product_id") REFERENCES "Product" ("product_id")
        ON DELETE CASCADE
);

CREATE TABLE "Located_At" (
    "branch_id" INT NOT NULL,
    "product_id" INT NOT NULL,
    "quantity" INT NOT NULL
        CHECK ( "quantity" > 0 ),
        CONSTRAINT "located_at_pk" PRIMARY KEY ("branch_id", "product_id"),
        CONSTRAINT "located_at_branch" FOREIGN KEY ("branch_id") REFERENCES "Branch" ("branch_id")
        ON DELETE CASCADE,
        CONSTRAINT "located_at_product" FOREIGN KEY ("product_id") REFERENCES "Product" ("product_id")
        ON DELETE CASCADE
);

----------------------------------------------------- INSERT DATA -----------------------------------------------------

INSERT INTO "Branch" ("branch_name", "address", "phone_number")
VALUES ('Fruit Haven', 'Maple Street 45, New York, 10001', '+123987654321');
INSERT INTO "Branch" ("branch_name", "address", "phone_number")
VALUES ('Veggie Corner', 'Oak Avenue 99, Los Angeles, 90001', '+321123456789');

INSERT INTO "Sale" ("sale_date", "total_price", "total_weight", "item_count", "branch_id")
VALUES (TO_DATE('2023-04-15', 'yyyy/mm/dd'), 150, 10, 3, 1);
INSERT INTO "Sale" ("sale_date", "total_price", "total_weight", "item_count", "branch_id")
VALUES (TO_DATE('2023-04-12', 'yyyy/mm/dd'), 90, 5, 1, 2);

INSERT INTO "Product" ("type", "product_name", "weight", "expiry_date", "selling_price")
VALUES ('fruit', 'Orange', 1, TO_DATE('2023-05-01', 'yyyy/mm/dd'), 35);
INSERT INTO "Product" ("type", "product_name", "weight", "expiry_date", "selling_price")
VALUES ('vegetable', 'Onion', 3, TO_DATE('2023-05-10', 'yyyy/mm/dd'), 20);
INSERT INTO "Product" ("type", "product_name", "weight", "expiry_date", "selling_price")
VALUES ('fruit', 'Pear', 2, TO_DATE('2023-05-03', 'yyyy/mm/dd'), 40);

INSERT INTO "Supplier" ("company_name", "address", "phone_number", "email")
VALUES ('Fr Ex', 'Baker St 221, London', '+441234567890', 'contact@frex.com');
INSERT INTO "Supplier" ("company_name", "address", "phone_number", "email")
VALUES ('GrMart', 'Sunset 1, Los Angeles', '+331234567890', 'sales@grmart.com');
INSERT INTO "Supplier" ("company_name", "address", "phone_number", "email")
VALUES ('Agro Sol', 'Road 55, Chicago', '+551234567890', 'info@agrosol.com');

INSERT INTO "Delivery" ("supplier_id", "delivery_date", "total_price", "total_weight", "item_count")
VALUES (1, TO_DATE('2025-01-01', 'yyyy/mm/dd'), 50, 2, 2);
INSERT INTO "Delivery" ("supplier_id", "delivery_date", "total_price", "total_weight", "item_count")
VALUES (2, TO_DATE('2025-01-02', 'yyyy/mm/dd'), 40, 3, 1);
INSERT INTO "Delivery" ("supplier_id", "delivery_date", "total_price", "total_weight", "item_count")
VALUES (3, TO_DATE('2025-01-03', 'yyyy/mm/dd'), 60, 4, 2);


-- extra INSERT to display data in the tables
INSERT INTO "Located_At" ("branch_id", "product_id", "quantity")
VALUES (1, 1, 15);
INSERT INTO "Located_At" ("branch_id", "product_id", "quantity")
VALUES (1, 3, 20);
INSERT INTO "Located_At" ("branch_id", "product_id", "quantity")
VALUES (2, 2, 10);
INSERT INTO "Located_At" ("branch_id", "product_id", "quantity")
VALUES (2, 3, 5);

INSERT INTO "Sold" ("sale_id", "product_id", "quantity")
VALUES (1, 1, 3);
INSERT INTO "Sold" ("sale_id", "product_id", "quantity")
VALUES (1, 3, 1);
INSERT INTO "Sold" ("sale_id", "product_id", "quantity")
VALUES (2, 2, 2);
INSERT INTO "Sold" ("sale_id", "product_id", "quantity")
VALUES (2, 3, 2);

INSERT INTO "Price_history" ("product_id", "price_date", "price")
VALUES (1, TO_DATE('2023-04-01', 'yyyy/mm/dd'), 30);
INSERT INTO "Price_history" ("product_id", "price_date", "price")
VALUES (2, TO_DATE('2023-04-01', 'yyyy/mm/dd'), 18);
INSERT INTO "Price_history" ("product_id", "price_date", "price")
VALUES (3, TO_DATE('2023-04-01', 'yyyy/mm/dd'), 38);
INSERT INTO "Price_history" ("product_id", "price_date", "price")
VALUES (3, TO_DATE('2023-03-20', 'yyyy/mm/dd'), 36);

-- add a new branch that stores no products (to be shown in 7. table - IN with nested SELECT)
INSERT INTO "Branch" ("branch_name", "address", "phone_number")
VALUES ('Empty Branch', 'No Product Blvd 1, Houston, 77001', '+999111222333');

------------------------------------------------------ SELECT ----------------------------------------------------------

-- all deliveries from the company Fr Ex (delivery ID, delivery date, total price)
-- joining 2 tables: delivery and supplier
SELECT "delivery_id", "delivery_date", "total_price"
FROM "Delivery"
JOIN "Supplier" ON "Delivery"."supplier_id" = "Supplier"."supplier_id"
WHERE "company_name" = 'Fr Ex';

-- get the total price of all deliveries from the company Fr Ex (total_price)
-- joining 2 tables: delivery and supplier
SELECT SUM("total_price") AS "Total price from Fr Ex"
FROM "Delivery"
JOIN "Supplier" ON "Delivery"."supplier_id" = "Supplier"."supplier_id"
WHERE "company_name" = 'Fr Ex';

-- show which products are available in each branch and in what quantity (branch name, product name, quantity)
-- joining 3 tables: located_at, branch, product
SELECT "Branch"."branch_name", "Product"."product_name", "Located_At"."quantity"
FROM "Located_At"
JOIN "Branch" ON "Located_At"."branch_id" = "Branch"."branch_id"
JOIN "Product" ON "Located_At"."product_id" = "Product"."product_id"
ORDER BY "Branch"."branch_name", "Product"."product_name";

-- show total quantity sold of each product (product name, total sold quantity)
-- GROUP BY, aggregation function
SELECT "Product"."product_name", SUM("quantity") AS "Total sold"
FROM "Sold"
JOIN "Product" ON "Sold"."product_id" = "Product"."product_id"
GROUP BY "Product"."product_name";

-- show total quantity of products stored in each branch (branch name, total stored quantity)
-- GROUP BY, aggregation function
SELECT "Branch"."branch_name", SUM("Located_At"."quantity") AS "Total in stock"
FROM "Located_At"
JOIN "Branch" ON "Located_At"."branch_id" = "Branch"."branch_id"
GROUP BY "Branch"."branch_name";

-- find products that have a price history entry (product name, price, date of price entry)
-- EXISTS
SELECT "product_name", "price", "price_date"
FROM "Product"
JOIN "Price_history" ON "Product"."product_id" = "Price_history"."product_id"
WHERE EXISTS (
    SELECT 1
    FROM "Price_history" ph
    WHERE ph."product_id" = "Product"."product_id"
);

-- show branches that do not store any products (branch name)
-- IN with a nested SELECT
SELECT "branch_name"
FROM "Branch"
WHERE "branch_id" NOT IN (
    SELECT DISTINCT "branch_id"
    FROM "Located_At"
);

------------------------------------------------------ TRIGGERS -------------------------------------------------------

-- create sequence
CREATE SEQUENCE "sale_seq"
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- first trigger generate sale_id 
CREATE OR REPLACE TRIGGER "sale_id_trigger"
    BEFORE INSERT ON "Sale"
    FOR EACH ROW
    WHEN (NEW."sale_id" IS NULL)
BEGIN
    :NEW."sale_id" := "sale_seq".NEXTVAL;
END;
/

-- second trigger ensure enough stock before inserting Sold
CREATE OR REPLACE TRIGGER "sold_quantity_check"
    BEFORE INSERT ON "Sold"
    FOR EACH ROW
    DECLARE
        v_total_qty INT;
        v_branch_id INT;
    BEGIN
        SELECT branch_id INTO v_branch_id FROM "Sale" WHERE sale_id = :NEW.sale_id;
        SELECT SUM(quantity) INTO v_total_qty
            FROM "Located_At"
        WHERE branch_id = v_branch_id
            AND product_id = :NEW.product_id
        GROUP BY branch_id, product_id;
        IF :NEW.quantity > NVL(v_total_qty,0) THEN
        RAISE_APPLICATION_ERROR(-20002,'Not enough stock in branch');
        END IF;
    END;
/

-- last trigger for decrementation after sold
CREATE OR REPLACE TRIGGER update_stock_after_sold
    AFTER INSERT ON "Sold"
    FOR EACH ROW
    DECLARE
    v_branch_id INT;
    BEGIN
        SELECT branch_id INTO v_branch_id FROM "Sale" WHERE sale_id = :NEW.sale_id;
        UPDATE "Located_At"
            SET quantity = quantity - :NEW.quantity
        WHERE branch_id = v_branch_id
            AND product_id = :NEW.product_id;
    END;
/

-------------------------------------------------------- TRIGGER DEMONSTRATION ----------------------------------------------------

-- first, insert into Sale without specifying sale_id. sequence and trigger will assign IDs
INSERT INTO "Sale" ("sale_date","total_price","total_weight","item_count","branch_id")
VALUES (TO_DATE('2025-05-01','YYYY-MM-DD'), 100, 5, 2, 1);
INSERT INTO "Sale" ("sale_date","total_price","total_weight","item_count","branch_id")
VALUES (TO_DATE('2025-05-02','YYYY-MM-DD'), 200, 10, 4, 1);

-- display IDs
SELECT "sale_id", "sale_date", "total_price"
FROM "Sale"
ORDER BY "sale_id";

-- second, attempt to sell more than in stock (branch 1 has 15 of product 1). this should raise an error and not insert
-- INSERT INTO "Sold" ("sale_id","product_id","quantity")
-- VALUES (1, 1, 100);

-- valid sale within stock limits
INSERT INTO "Sold" ("sale_id","product_id","quantity")
VALUES (1, 1, 5);
-- sold check
SELECT * FROM "Sold" WHERE sale_id = 1 AND product_id = 1;

-- check updated stock in Located_At for branch 1, product 1
SELECT "branch_id", "product_id", "quantity"
FROM "Located_At"
WHERE "branch_id" = 1 AND "product_id" = 1;

-------------------------------------------------- PROCEDURES --------------------------------------------------

-- first, calculate and print percentage of sold vs total stock for each product
CREATE OR REPLACE PROCEDURE count_percent_of_sold_products IS
    -- name and counts using %TYPE
    v_prod_name    "Product"."product_name"%TYPE;
    v_sold_qty     NUMBER;
    v_stock_qty    NUMBER;
    -- cursor over products and sold quantities
    CURSOR c_prod IS
      SELECT p."product_name", COALESCE(SUM(s."quantity"),0) AS sold_qty
        FROM "Product" p
        LEFT JOIN "Sold" s
          ON p."product_id" = s."product_id"
       GROUP BY p."product_name";
BEGIN
    OPEN c_prod;
    LOOP
        FETCH c_prod INTO v_prod_name, v_sold_qty;
        EXIT WHEN c_prod%NOTFOUND;
        -- get total stock for this product
        SELECT COALESCE(SUM("quantity"),0)
          INTO v_stock_qty
          FROM "Located_At" la
         JOIN "Branch" b ON la."branch_id" = b."branch_id"
         JOIN "Product" p2 ON la."product_id" = p2."product_id"
         WHERE p2."product_name" = v_prod_name;
        -- handle zero stock
        IF v_stock_qty = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Product: '||v_prod_name||' has no stock');
        ELSE
            DBMS_OUTPUT.PUT_LINE(
              'Product: '||v_prod_name||
              ' | Sold = '||v_sold_qty||
              ' | Stock = '||v_stock_qty||
              ' | '||ROUND(v_sold_qty/v_stock_qty*100,2)||'% sold'
            );
        END IF;
    END LOOP;
    CLOSE c_prod;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Division by zero for '||v_prod_name);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: '||SQLERRM);
END;
/

-- call demonstration
BEGIN
    count_percent_of_sold_products;
END;
/

-- second, report branches storing a given product and their quantities
CREATE OR REPLACE PROCEDURE report_product_locations(p_name IN VARCHAR2) IS
    -- record type for output
    TYPE t_loc_rec IS RECORD (
        branch_name "Branch"."branch_name"%TYPE,
        qty         "Located_At"."quantity"%TYPE
    );
    v_loc_rec    t_loc_rec;
    CURSOR c_loc IS
      SELECT b."branch_name", la."quantity"
        FROM "Located_At" la
        JOIN "Branch" b ON la."branch_id" = b."branch_id"
        JOIN "Product" p ON la."product_id" = p."product_id"
       WHERE p."product_name" = p_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Locations for product: '||p_name);
    OPEN c_loc;
    LOOP
        FETCH c_loc INTO v_loc_rec;
        EXIT WHEN c_loc%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
          'Branch: '||v_loc_rec.branch_name||', Qty: '||v_loc_rec.qty
        );
    END LOOP;
    CLOSE c_loc;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No locations found for '||p_name);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: '||SQLERRM);
END;
/

-- call demonstration
BEGIN
    report_product_locations('Orange');
END;
/

-- with case
-- for each branch its total revenue, total items sold and a revenue category (high or medium or low)
WITH sales_summary AS (
  SELECT
    "branch_id",
    SUM(total_price) AS total_revenue,
    SUM(item_count)  AS total_items_sold
  FROM "Sale"
  GROUP BY "branch_id"
)
SELECT
  b."branch_name",
  ss.total_revenue,
  ss.total_items_sold,
  CASE
    WHEN ss.total_revenue > 200 THEN 'High'
    WHEN ss.total_revenue > 100 THEN 'Medium'
    ELSE 'Low'
  END AS revenue_category
FROM sales_summary ss
JOIN "Branch" b
  ON b."branch_id" = ss."branch_id";

-------------------------------------------------- EXPLAIN PLAN --------------------------------------------------

-- drop existing index
DROP INDEX "sold_prod_idx";

-- for total sold per product without index
EXPLAIN PLAN FOR
SELECT p."product_name", SUM(s."quantity") AS total_sold
  FROM "Sold" s
  JOIN "Product" p ON s."product_id" = p."product_id"
 GROUP BY p."product_name";
-- display the plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- create index on Sold
CREATE INDEX "sold_prod_idx" ON "Sold"("product_id");

-- rerun EXPLAIN PLAN with index
EXPLAIN PLAN FOR
SELECT p."product_name", SUM(s."quantity") AS total_sold
  FROM "Sold" s
  JOIN "Product" p ON s."product_id" = p."product_id"
 GROUP BY p."product_name";
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-------------------------------------------------- PRIVILEGES --------------------------------------------------

GRANT ALL ON "Branch" TO xramas01;
GRANT ALL ON "Sale" TO xramas01;
GRANT ALL ON "Product" TO xramas01;
GRANT ALL ON "Price_history" TO xramas01;
GRANT ALL ON "Supplier" TO xramas01;
GRANT ALL ON "Delivery" TO xramas01;
GRANT ALL ON "Sold" TO xramas01;
GRANT ALL ON "Located_At" TO xramas01;

-------------------------------------------------- MATERIALIZED VIEW --------------------------------------------------

-- materialized view showing stock per branch/product
CREATE MATERIALIZED VIEW "branch_stock_mv"
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    AS
SELECT b."branch_name",
       p."product_name",
       la."quantity"
  FROM xfedor14."Located_At" la
  JOIN xfedor14."Branch" b ON la."branch_id" = b."branch_id"
  JOIN xfedor14."Product" p ON la."product_id" = p."product_id";

-- materialized view demonstration

SELECT * FROM "branch_stock_mv";
-- insert new data into base tables
INSERT INTO xfedor14."Located_At" ("branch_id","product_id","quantity")
VALUES (1, 2, 5);

BEGIN
  DBMS_MVIEW.REFRESH('branch_stock_mv','FAST');
END;
/

SELECT * FROM "branch_stock_mv";

GRANT SELECT ON "branch_stock_mv" TO xramas01;
