-- Sample data for the portfolio version

INSERT INTO branch (branch_name, address, phone_number)
VALUES ('Fruit Haven', 'Maple Street 45, New York, 10001', '+123987654321');

INSERT INTO branch (branch_name, address, phone_number)
VALUES ('Veggie Corner', 'Oak Avenue 99, Los Angeles, 90001', '+321123456789');

INSERT INTO branch (branch_name, address, phone_number)
VALUES ('Empty Branch', 'No Product Blvd 1, Houston, 77001', '+999111222333');

INSERT INTO product (product_type, product_name, weight, expiry_date, selling_price)
VALUES ('fruit', 'Orange', 1, DATE '2025-05-01', 35);

INSERT INTO product (product_type, product_name, weight, expiry_date, selling_price)
VALUES ('vegetable', 'Onion', 3, DATE '2025-05-10', 20);

INSERT INTO product (product_type, product_name, weight, expiry_date, selling_price)
VALUES ('fruit', 'Pear', 2, DATE '2025-05-03', 40);

INSERT INTO supplier (company_name, address, phone_number, email)
VALUES ('Fr Ex', 'Baker St 221, London', '+441234567890', 'contact@frex.com');

INSERT INTO supplier (company_name, address, phone_number, email)
VALUES ('GrMart', 'Sunset 1, Los Angeles', '+331234567890', 'sales@grmart.com');

INSERT INTO supplier (company_name, address, phone_number, email)
VALUES ('Agro Sol', 'Road 55, Chicago', '+551234567890', 'info@agrosol.com');

INSERT INTO delivery (supplier_id, delivery_date, total_price, total_weight, item_count)
VALUES (1, DATE '2025-01-01', 50, 2, 2);

INSERT INTO delivery (supplier_id, delivery_date, total_price, total_weight, item_count)
VALUES (2, DATE '2025-01-02', 40, 3, 1);

INSERT INTO delivery (supplier_id, delivery_date, total_price, total_weight, item_count)
VALUES (3, DATE '2025-01-03', 60, 4, 2);

INSERT INTO sale (sale_date, total_price, total_weight, item_count, branch_id)
VALUES (DATE '2025-04-15', 150, 10, 3, 1);

INSERT INTO sale (sale_date, total_price, total_weight, item_count, branch_id)
VALUES (DATE '2025-04-12', 90, 5, 1, 2);

INSERT INTO located_at (branch_id, product_id, quantity) VALUES (1, 1, 15);
INSERT INTO located_at (branch_id, product_id, quantity) VALUES (1, 3, 20);
INSERT INTO located_at (branch_id, product_id, quantity) VALUES (2, 2, 10);
INSERT INTO located_at (branch_id, product_id, quantity) VALUES (2, 3, 5);

INSERT INTO sold (sale_id, product_id, quantity) VALUES (1, 1, 3);
INSERT INTO sold (sale_id, product_id, quantity) VALUES (1, 3, 1);
INSERT INTO sold (sale_id, product_id, quantity) VALUES (2, 2, 2);
INSERT INTO sold (sale_id, product_id, quantity) VALUES (2, 3, 2);

INSERT INTO price_history (product_id, price_date, price)
VALUES (1, DATE '2025-04-01', 30);

INSERT INTO price_history (product_id, price_date, price)
VALUES (2, DATE '2025-04-01', 18);

INSERT INTO price_history (product_id, price_date, price)
VALUES (3, DATE '2025-04-01', 38);

INSERT INTO price_history (product_id, price_date, price)
VALUES (3, DATE '2025-03-20', 36);

COMMIT;
