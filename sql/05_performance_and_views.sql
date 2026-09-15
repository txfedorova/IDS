-- Performance analysis, indexing and materialized view examples

-- Query plan before adding an explicit index.
EXPLAIN PLAN FOR
SELECT p.product_name,
       SUM(s.quantity) AS total_sold
FROM sold s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_name;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Index supporting lookups and aggregations by product_id.
BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX sold_product_idx';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE INDEX sold_product_idx ON sold(product_id);

-- Query plan after adding the index.
EXPLAIN PLAN FOR
SELECT p.product_name,
       SUM(s.quantity) AS total_sold
FROM sold s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_name;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Materialized view with an inventory snapshot.
-- COMPLETE refresh keeps the example self-contained and does not require
-- materialized-view logs on the base tables.
BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW branch_stock_mv';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE MATERIALIZED VIEW branch_stock_mv
    BUILD IMMEDIATE
    REFRESH COMPLETE ON DEMAND
AS
SELECT b.branch_id,
       b.branch_name,
       p.product_id,
       p.product_name,
       la.quantity
FROM located_at la
JOIN branch b ON b.branch_id = la.branch_id
JOIN product p ON p.product_id = la.product_id;

SELECT *
FROM branch_stock_mv
ORDER BY branch_name, product_name;

-- Refresh after base-table data changes.
BEGIN
    DBMS_MVIEW.REFRESH('BRANCH_STOCK_MV', 'C');
END;
/

-- Example privilege statement for a real application user:
-- GRANT SELECT ON branch_stock_mv TO reporting_user;
