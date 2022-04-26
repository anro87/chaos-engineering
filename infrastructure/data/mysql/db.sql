create database if not exists cecs;

use cecs;

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customerId varchar(36),
    name varchar(255)
);

INSERT INTO customers (customerId, name)
VALUES 
    ('36001a81-1acc-4689-b193-9ad26bfdb9e1', 'Megaton'),
    ('59746e41-7e1f-452f-8b8d-7dd57274f150', 'Oxygen Tech.'),
    ('20549bce-2faf-43cb-ab1c-33ca58c3324e', 'Unien INNO');