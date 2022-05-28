\c unidad2
--psql -U juancaf unidad2 < unidad2.sql

--El cliente usuario01 ha realizado la siguiente compra:

--producto: producto9.
-- cantidad: 5.
--fecha: fecha del sistema

SELECT * FROM producto WHERE id = 9;
BEGIN TRANSACTION;

    INSERT INTO compra (cliente_id,fecha) VALUES ((SELECT id FROM cliente WHERE nombre = 'usuario01'),current_timestamp);
    INSERT INTO detalle_compra (producto_id,compra_id,cantidad) VALUES ((SELECT id FROM producto WHERE descripcion = 'producto9'),(SELECT MAX(id) FROM compra),5);
    UPDATE producto SET stock = stock - 5 WHERE descripcion = 'producto9';

COMMIT;
SELECT * FROM producto WHERE id = 9;

--El cliente usuario02 ha realizado la siguiente compra:
--● producto: producto1, producto 2, producto 8.
--● cantidad: 3 de cada producto.
--● fecha: fecha del sistema.

--Mediante el uso de transacciones, realiza las consultas correspondientes para este requerimiento y luego consulta la tabla producto para validar que si alguno de ellos se queda sin stock, no se realice la compra.

select * from producto where descripcion = 'producto1' or descripcion = 'producto2' or descripcion = 'producto8';

BEGIN TRANSACTION;

    INSERT INTO compra(cliente_id,fecha) VALUES ((SELECT id FROM cliente WHERE nombre = 'usuario02'),current_timestamp);
    INSERT INTO detalle_compra (producto_id,compra_id,cantidad) VALUES ((SELECT id FROM producto WHERE descripcion = 'producto1'),(SELECT MAX(id) FROM compra),3);
    UPDATE producto SET stock = stock - 3 WHERE descripcion = 'producto1';
    SAVEPOINT compra1;
COMMIT;

BEGIN TRANSACTION;
    INSERT INTO compra(cliente_id,fecha) VALUES ((SELECT id FROM cliente WHERE nombre = 'usuario02'),current_timestamp);
    INSERT INTO detalle_compra (producto_id,compra_id,cantidad) VALUES ((SELECT id FROM producto WHERE descripcion = 'producto2'),
    (SELECT MAX(id) FROM compra),3);
    UPDATE producto SET stock = stock - 3 WHERE descripcion = 'producto2';
    SAVEPOINT compra2;
COMMIT;

BEGIN TRANSACTION;
    INSERT INTO compra(cliente_id,fecha) VALUES ((SELECT id FROM cliente WHERE nombre = 'usuario02'),current_timestamp);
    INSERT INTO detalle_compra (producto_id,compra_id,cantidad) VALUES ((SELECT id FROM producto WHERE descripcion = 'producto8'),
    (SELECT MAX(id) FROM compra),3);
    UPDATE producto SET stock = stock - 3 WHERE descripcion = 'producto8';
    ROLLBACK TO compra2;
COMMIT;

select * from producto where id = 1 or id = 2 or id = 8 order by id asc;

--Deshabilitar el AUTOCOMMIT .

\set AUTOCOMMIT off

--Insertar un nuevo cliente.

BEGIN TRANSACTION;
    SELECT * FROM cliente;
    SAVEPOINT agregar1;
    INSERT INTO cliente (nombre,email) VALUES ('usuario11', 'usuario11@gmail.com');
    --Confirmar que fue agregado en la tabla cliente.
    SELECT * FROM cliente WHERE nombre = 'usuario11';
    --Realizar un ROLLBACK.
    ROLLBACK TO agregar1;
    --Confirmar que se restauró la información, sin considerar la inserción del punto b.
    SELECT * FROM cliente;
COMMIT;

--Habilitar de nuevo el AUTOCOMMIT.

\set AUTOCOMMIT on


