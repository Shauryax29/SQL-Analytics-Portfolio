create database Creditcard;
use Creditcard;
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    City VARCHAR(255),
    Date DATE,
    Card_Type VARCHAR(50),
    Exp_Type VARCHAR(50),
    Gender VARCHAR(10),
    Amount DECIMAL(10, 2)
);

SELECT * FROM transactions LIMIT 10;
SELECT count(*) FROM transactions;
-- See all unique cities
SELECT DISTINCT City FROM transactions;

-- See all unique card types
SELECT DISTINCT Card_Type FROM transactions;

-- See all unique expense types
SELECT DISTINCT Exp_Type FROM transactions;
