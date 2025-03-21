/*
=======================================================================================
Stored Procedure: Load Silver Layer (from Bronze to Silver Layer)
=======================================================================================
Script Purpose: 
    This Stored Procedure performs transformations on Bronze Layer tables and then inserts them
    into the Silver Layer tables.

Actions Performed:
   (1) Truncates the Silver Tables (removes any existing data).
   (2) Inserts cleaned and transformed data from Bronze tables to Silver tables

Parameters:
    - None (this Stored Procedure does not accept paramters, nor does it return any values.)

Usage Example:
    CALL silver.load_silver();
=======================================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver() LANGUAGE plpgsql
AS $$
BEGIN
	--Now that we've gone ahead and done the various data clean-ups on the bronze columns, we are ready to insert the cleaned up / standardized data into our silver layer table...
	
	-------------------------------------------

	--CRM Table #1: crm_cust_info
	--crm_cust_info--
	--we're doing transformations to clean up data from the bronze layer and insert it into the silver layer
	TRUNCATE TABLE silver.crm_cust_info; 
	INSERT INTO silver.crm_cust_info (
		cst_id
		,cst_key
		,cst_firstname
		,cst_lastname
		,cst_marital_status
		,cst_gndr
		,cst_create_date
	)
	SELECT 
		cst_id
		,cst_key
		,TRIM(cst_firstname)
		,TRIM(cst_lastname)
		,CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END as cst_marital_status
		,CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END as cst_gndr
		,cst_create_date
	FROM (
		SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info
		--WHERE cst_id = 29483
	)t
	WHERE flag_last = 1;
	
	-----------------------------------------------

	--CRM Table #2: crm_prd_info
	--crm_prd_info
	--we're doing transformations to clean up data from the bronze layer and insert it into the silver layer
	TRUNCATE TABLE silver.crm_prd_info; 
	INSERT INTO silver.crm_prd_info (
		prd_id
		,cat_id
		,prd_key
		,prd_nm
		,prd_cost
		,prd_line
		,prd_start_dt
		,prd_end_dt
	)
	SELECT 
		prd_id
		,REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') as cat_id
		,SUBSTRING(prd_key,7,LENGTH(prd_key)) as prd_key
		,prd_nm
		,COALESCE(prd_cost,0) as prd_cost
	 	,CASE
			WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
			WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			ELSE 'n/a'
		END as prd_line
		,CAST(prd_start_dt as DATE)
		,CAST((LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)) - INTERVAL '1 day' as DATE) as prd_end_dt
	FROM bronze.crm_prd_info;
	
	-----------------------------------------------

	--CRM Table #3: crm_sales_details
	--crm_sales_details
	--we're doing transformations to clean up data from the bronze layer and insert it into the silver layer
	TRUNCATE TABLE silver.crm_sales_details; 
	INSERT INTO silver.crm_sales_details (
		sls_ord_num
		,sls_prd_key
		,sls_cust_id
		,sls_order_dt
		,sls_ship_dt
		,sls_due_dt
		,sls_sales
		,sls_quantity
		,sls_price
	)
	SELECT
		sls_ord_num
		,sls_prd_key
		,sls_cust_id
		,CASE 
			WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::VARCHAR) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt as VARCHAR) as DATE)
		END as sls_order_dt
		,CASE 
			WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::VARCHAR) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt as VARCHAR) as DATE)
		END as sls_ship_dt
		,CASE 
			WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::VARCHAR) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt as VARCHAR) as DATE)
		END as sls_due_dt
		,CASE 
			WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END as sls_sales
		,sls_quantity
		,CASE
			WHEN sls_price IS NULL OR sls_price <= 0
				THEN sls_sales / COALESCE(sls_quantity, 0)
			ELSE sls_price
		END as sls_price
	FROM bronze.crm_sales_details;
	
	-----------------------------------------------

	--ERP Table #1: erp_cust_az12
	--erp_cust_az12
	--we're doing transformations to clean up data from the bronze layer and insert it into the silver layer
	TRUNCATE TABLE silver.erp_cust_az12; 
	INSERT INTO silver.erp_cust_az12 (
		cid
		,bdate
		,gen
	)
	SELECT 
		CASE
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
			ELSE cid
		END as cid
		,CASE 
			WHEN bdate > CURRENT_DATE THEN NULL
			ELSE bdate
		END as bdate
		,CASE 
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			ELSE 'n/a'
		END as gen
	FROM bronze.erp_cust_az12;
	
	-----------------------------------------------

	--ERP Table #2: erp_loc_a101
	--erp_loc_a101
	--we're doing transformations to clean up data from the bronze layer and insert it into the silver layer
	TRUNCATE TABLE silver.erp_loc_a101; 
	INSERT into silver.erp_loc_a101 (
		cid
		,cntry
	)
	SELECT
		REPLACE(cid,'-','') as cid
		,CASE
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END as cntry
	FROM bronze.erp_loc_a101;
	
	
	-----------------------------------------------

	--ERP Table #3: erp_px_cat_g1v2
	--erp_px_cat_g1v2
	--we're doing transformations to clean up data from the bronze layer and insert it into the silver layer
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	INSERT INTO silver.erp_px_cat_g1v2 (
		id
		,cat
		,subcat
		,maintenance
	)
	SELECT
		id
		,cat
		,subcat
		,maintenance
	FROM bronze.erp_px_cat_g1v2;
	
END; $$;
