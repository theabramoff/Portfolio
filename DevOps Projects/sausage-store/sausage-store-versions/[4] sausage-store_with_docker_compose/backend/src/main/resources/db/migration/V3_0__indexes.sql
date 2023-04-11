
CREATE INDEX id_index ON product (id);

CREATE INDEX order_id_index ON order_product (order_id);

CREATE INDEX product_id_index ON order_product (product_id);

CREATE INDEX orders_index ON orders (id);