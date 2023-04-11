
As per the querry select COUNT(*) from orders o INNER JOIN order_product op ON o.id = op.order_id INNER JOIN product p ON op.product_id = p.id WHERE p.id = 2;
Default Indexes BTREE are created for respective columns in tables:

#1
CREATE INDEX CONCURRENTLY id_index ON product USING BTREE(id);
#2
CREATE INDEX CONCURRENTLY order_id_index ON order_product USING BTREE(order_id);
#3
CREATE INDEX CONCURRENTLY product_id_index ON order_product USING BTREE(product_id);
#4
CREATE INDEX CONCURRENTLY orders_index ON orders USING BTREE(id);

#List of relations
 Schema |       Name       | Type  |    Owner    |     Table     | Persistence | Access method |  Size  | Description
--------+------------------+-------+-------------+---------------+-------------+---------------+--------+-------------
 public | id_index         | index | theabramoff | product       | permanent   | btree         | 16 kB  |
 public | order_id_index   | index | theabramoff | order_product | permanent   | btree         | 214 MB |
 public | orders_index     | index | theabramoff | orders        | permanent   | btree         | 214 MB |
 public | product_id_index | index | theabramoff | order_product | permanent   | btree         | 66 MB  |