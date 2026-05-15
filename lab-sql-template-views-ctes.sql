-- First, create a view that summarizes rental information for each customer.
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
USE sakila;
DROP VIEW IF EXISTS customer_rental_summary;
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r -- coincide enunciado TODOS
    ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, 
    c.first_name,   
    c.last_name,    
    c.email;           
SELECT * FROM customer_rental_summary
ORDER BY rental_count DESC
LIMIT 10;	

-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
--  The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
-- and calculate the total amount paid by each customer.

DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM customer_rental_summary crs
LEFT JOIN rental r
    ON crs.customer_id = r.customer_id
LEFT JOIN payment p
    ON r.rental_id = p.rental_id
GROUP BY crs.customer_id;

-- Checking the temporary table
SELECT *
FROM customer_payment_summary
ORDER BY total_paid DESC
LIMIT 10;

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include:
-- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from 
-- total paid and rental_count  
WITH customer_summary AS (
    SELECT 
        crs.customer_id,
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid,
        CASE 
            WHEN crs.rental_count = 0 THEN 0
            ELSE ROUND(cps.total_paid / crs.rental_count, 2)
        END AS average_payment_per_rental
    FROM customer_rental_summary crs
    LEFT JOIN customer_payment_summary cps
        ON crs.customer_id = cps.customer_id
)
SELECT 
    customer_id,
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC;



