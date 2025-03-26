/*
=====================================================
Create Gold Layer (Views)
=====================================================

Script Purpose:
This SQL script is used to create the Gold Layer "Views" that will be used for analytics & reporting.
------------------------------------------------------------------------------------------------------------------------------
*/

/*Creating Views for our 'Gold' schema -- this schema is what will be used for analytics & reporting.  Here we combine our various 'Silver' 
  schema tables together into more meaningful views for reporting and business end-users.*/

--===========================================================
--create the Customers dimension VIEW...
--===========================================================
CREATE OR REPLACE VIEW gold.dim_customers AS
(
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) as customer_key
	,ci.cst_id as customer_id
	,ci.cst_key as customer_number
	,ci.cst_firstname as first_name
	,ci.cst_lastname as last_name
	,la.cntry as country
	,ci.cst_marital_status as marital_status
	,CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the Master for gender Info
		ELSE COALESCE(bd.gen, 'n/a')
	END as gender	
	,bd.bdate as birthdate
	,ci.cst_create_date as create_date
FROM silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as bd
	ON ci.cst_key = bd.cid
LEFT JOIN silver.erp_loc_a101 as la
	ON ci.cst_key = la.cid
)
;


--===========================================================
--create the Products dimension VIEW...
--===========================================================
CREATE OR REPLACE VIEW gold.dim_products AS
(
	SELECT
		ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) as product_key
		,pi.prd_id as product_id
		,pi.prd_key as product_number
		,pi.prd_nm as product_name
		,pi.cat_id as category_id
		,pc.cat as category
		,pc.subcat as subcategory
		,pc.maintenance
		,pi.prd_cost as cost
		,pi.prd_line as product_line
		,pi.prd_start_dt as start_date	
	FROM silver.crm_prd_info as pi 
	LEFT JOIN silver.erp_px_cat_g1v2 as pc
		ON pi.cat_id = pc.id
	WHERE pi.prd_end_dt is NULL --Filter out all historical data
)
;


--===========================================================
--create the Sales fact VIEW...
--===========================================================
CREATE OR REPLACE VIEW gold.fact_sales AS
(
	SELECT
		sd.sls_ord_num as order_number
		,pr.product_key
		--,sd.sls_prd_key
		,cu.customer_key
		--,sd.sls_cust_id
		,sd.sls_order_dt as order_date
		,sd.sls_ship_dt as shipping_date
		,sd.sls_due_dt as due_date
		,sd.sls_sales as sales_amount
		,sd.sls_quantity as quantity
		,sd.sls_price as price
	FROM silver.crm_sales_details as sd
	LEFT JOIN gold.dim_products as pr
		ON sd.sls_prd_key = pr.product_number
	LEFT JOIN gold.dim_customers as cu
		ON sd.sls_cust_id = cu.customer_id
)
;
