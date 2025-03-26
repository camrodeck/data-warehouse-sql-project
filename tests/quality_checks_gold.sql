

--data quality checks when joining fact & dimension tables together
SELECT 
	s.*
	,c.*
	,p.*
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
;


SELECT *
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
;
