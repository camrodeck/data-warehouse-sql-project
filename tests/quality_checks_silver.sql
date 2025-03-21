/*
=========================================================================================================
Quality Checks
=========================================================================================================
Script Purpose:
    This script performs various checks across tables created as part of the Silver layer.

Usage Notes:
    These can be run after loading the Silver Layer to look or data issues/inconsistencies.
    Any errors found should be further investigated and resolved to ensure that good quality data
      is being populated into the Silver Layer tables.
=========================================================================================================
*/

--Checks/Tests for our SILVER Layer TABLES--

--===============================
--==== crm_cust_info ==========
--===============================

--this checks to see if there are multiple records for the same customer id (i.e. there should only be one customer id record - these should be unique)
SELECT 
	cst_id,
	COUNT(1) as customer_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(1) > 1 OR cst_id IS NULL

--now can we check to see if certain text fields have leading or trailing white spaces
SELECT
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) 
	OR cst_lastname != TRIM(cst_lastname)
	OR cst_gndr != TRIM(cst_gndr)

--what distinct values do we have for the gender column - have we spelled out the values like 'Female', 'Male', 'n/a'?
SELECT 
	DISTINCT cst_gndr
FROM silver.crm_cust_info


--=============================================================================================\

--===============================
--==== crm_prd_info ==========
--===============================

--are there duplicate product ids?
SELECT
	prd_id
	,COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

--are there blank spaces in the product name?
SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--what are the distinct values of the product line column?
SELECT
	DISTINCT prd_line
FROM silver.crm_prd_info

--=============================================================================================\

--===============================
--==== crm_sales_details ========
--===============================

--checking for orders with invalid dates (i.e. is the order date greater than the ship date or due date?)
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--checking for incorrect math/values in the sales, quantity, & price fields
SELECT DISTINCT
	sls_sales
	,sls_quantity
	,sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

--=============================================================================================\

--===============================
--======= erp_cust_az12 ========
--===============================

-- do we have any birthdates that are dates in the future?
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE

--what distinct values do we have for gender in the cleaned-up table?
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12

--=============================================================================================\

--===============================
--======= erp_loc_a101 ========
--===============================

--what distinct country values do we have in the cleaned-up table?
SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry


--=============================================================================================\

--===============================
--======= erp_px_cat_g1v2 =======
--===============================

--are the category, subcategory, & maintenance fields trimmed of all blank spaces?
SELECT
	*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
	OR subcat != TRIM(subcat)
	OR maintenance != TRIM(maintenance)

--what are the distinct values in the maintenance column in the cleaned-up table?
SELECT DISTINCT
	maintenance
FROM silver.erp_px_cat_g1v2

