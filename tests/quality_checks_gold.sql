/*
=========================================================================================================
Quality Checks
=========================================================================================================
Script Purpose:
    This script performs various checks across views created as part of the Gold layer.

Usage Notes:
    Any errors found should be further investigated and resolved to ensure that good quality data
      is flowing through to the 'Gold' Views.
=========================================================================================================
*/

--Checks/Tests for our GOLD Layer VIEWS--

--=====================================================
--checking 'gold.dim_customers'
--=====================================================
-- Check for uniqueness of Customer Key
-- Expecatation: No results should be returned
SELECT 
	customer_key
	,COUNT(*) as duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1
;

--=====================================================
--checking 'gold.dim_products'
--=====================================================
-- Check for uniqueness of Product Key
-- Expecatation: No results should be returned
SELECT 
	product_key
	,COUNT(*) as duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1
;

--=====================================================
--checking 'gold.fact_sales'
--=====================================================
-- Check the data model connectivity between fact & dimensions
-- Expectation: No results should be returned.
SELECT *
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
WHERE s.product_key IS NULL OR c.customer_key IS NULL
;
