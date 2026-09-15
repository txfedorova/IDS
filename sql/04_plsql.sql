-- PL/SQL triggers and procedures
SET SERVEROUTPUT ON;

-- Prevent sales from exceeding the stock available in the corresponding branch.
CREATE OR REPLACE TRIGGER sold_quantity_check
    BEFORE INSERT OR UPDATE OF quantity ON sold
    FOR EACH ROW
DECLARE
    v_branch_id  sale.branch_id%TYPE;
    v_stock_qty  located_at.quantity%TYPE;
BEGIN
    SELECT branch_id
    INTO v_branch_id
    FROM sale
    WHERE sale_id = :NEW.sale_id;

    SELECT NVL(SUM(quantity), 0)
    INTO v_stock_qty
    FROM located_at
    WHERE branch_id = v_branch_id
      AND product_id = :NEW.product_id;

    IF :NEW.quantity > v_stock_qty THEN
        RAISE_APPLICATION_ERROR(-20002, 'Not enough stock in branch');
    END IF;
END;
/

-- Decrease branch stock after a product is added to a sale.
CREATE OR REPLACE TRIGGER update_stock_after_sold
    AFTER INSERT ON sold
    FOR EACH ROW
DECLARE
    v_branch_id sale.branch_id%TYPE;
BEGIN
    SELECT branch_id
    INTO v_branch_id
    FROM sale
    WHERE sale_id = :NEW.sale_id;

    UPDATE located_at
    SET quantity = quantity - :NEW.quantity
    WHERE branch_id = v_branch_id
      AND product_id = :NEW.product_id;
END;
/

-- Report sold and currently stocked quantities for each product.
CREATE OR REPLACE PROCEDURE report_product_sales_and_stock IS
    CURSOR c_products IS
        SELECT p.product_id,
               p.product_name,
               NVL(SUM(s.quantity), 0) AS sold_qty
        FROM product p
        LEFT JOIN sold s ON s.product_id = p.product_id
        GROUP BY p.product_id, p.product_name
        ORDER BY p.product_name;

    v_stock_qty NUMBER;
BEGIN
    FOR rec IN c_products LOOP
        SELECT NVL(SUM(quantity), 0)
        INTO v_stock_qty
        FROM located_at
        WHERE product_id = rec.product_id;

        DBMS_OUTPUT.PUT_LINE(
            'Product: ' || rec.product_name ||
            ' | Sold: ' || rec.sold_qty ||
            ' | Current stock: ' || v_stock_qty
        );
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- Report all branches where a given product is stored.
CREATE OR REPLACE PROCEDURE report_product_locations(
    p_name IN product.product_name%TYPE
) IS
    v_found BOOLEAN := FALSE;

    CURSOR c_locations IS
        SELECT b.branch_name,
               la.quantity
        FROM located_at la
        JOIN branch b ON b.branch_id = la.branch_id
        JOIN product p ON p.product_id = la.product_id
        WHERE p.product_name = p_name
        ORDER BY b.branch_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Locations for product: ' || p_name);

    FOR rec IN c_locations LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            'Branch: ' || rec.branch_name ||
            ' | Quantity: ' || rec.quantity
        );
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No locations found.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- Example calls
BEGIN
    report_product_sales_and_stock;
    report_product_locations('Orange');
END;
/
