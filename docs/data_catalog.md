# Data Catalog for "Gold" Layer of Warehouse

## Summary:
The Gold Layer is the top-level (business level) representation, structured to support analytical and reporting use cases.  It consists 
of **dimension tables** and **fact tables** for specific business metrics.

---

### 1. **gold.dim_customers**

   - **Purpose:** Stores customer details enriched with demographic (gender, birthdate) & geographic (country of residence) data.
   - **Columns:**

| Column Name | Data Type | Description |
|-------------|-----------|---------------------------------------------|
| customer_key|BIGINT| Surrogate key uniquely identifying each customer record in the dimension table.|  
| customer_id|INTEGER| Unique numerical identifier assigned to each customer.|  
| customer_number|CHARACTER VARYING (50)| Alphanumeric identifier representing the customer, used for tracking and referencing.|  
| first_name|CHARACTER VARYING (50)| The customer's first name, as recorded in the system.|  
| last_name|CHARACTER VARYING (50)| The customer's last name or surname.|  
| country|CHARACTER VARYING (50)| The country of residence of the customer (e.g. 'Germany').|  
| marital_status|CHARACTER VARYING (50)| The marital status of the customer (e.g. 'Married', 'Single').|  
| gender|CHARACTER VARYING| The gender of the customer (e.g. 'Male', 'Female', or 'n/a').|  
| birthdate|DATE| The date of birth of the customer, formatted as YYYY-MM-DD (e.g. 1990-01-15).|  
| create_date|DATE| The date when the customer record was created in the system.|  

---

### 2. **gold.dim_products**

  - **Purpose:** Provides product information and attributes of those products.
  - **Columns:**

| Column Name | Data Type | Description|
|------------|-----------|------------|
| product_key | BIGINT | Surrogate key uniquely identifying each product record in the product dimension table.|
| product_id | INTEGER | A unique identifier assigned to the product for internal tracking & referencing.|
| product_number | CHARACTER VARYING (50) | A structured alphanumeric code representing the product, often used for categorization or inventory.|
| product_name | CHARACTER VARYING (100) | Descriptive name of the product, including key details such as type, color, & size.|
| category_id| CHARACTER VARYING (50) | A unique identifier for the product's category, linking to its high-level classification.|
| category| CHARACTER VARYING (50) | The broader classification of the product (e.g. 'Bikes', 'Components') to group related items.|
| subcategory| CHARACTER VARYING (50) | A more detailed classification of the product within the category, such as product type.|
| maintenance | CHARACTER VARYING (50) | Indicates whether the product requires maintenance (e.g. 'Yes', or 'No').|
| cost | INTEGER | The cost or base price of the product, measured in monetary units.|
| product_line| CHARACTER VARYING (50) | The specific product line or series to which the product belongs (e.g. 'Road', 'Mountain').|
| start_date| DATE | The date when the product became available for sale or use - stored in YYYY-MM-DD format (e.g. 1990-01-15).|

### 3. **gold.fact_sales**

  - **Purpose:** Stores transactional sales data for analytical purposes.
  - **Columns:**

|Column Name|Data Type|Description|
|------------|---------|----------|
| order_number | CHARACTER VARYING (50) | A unique alaphnumeric identifier for each sales order (e.g. 'SO43697').|
| product_key | BIGINT | Foreign key linking the order to the product dimension table.|
| customer_key | BIGINT | Foreign key linking the order to the customer dimension table.|
| order_date | DATE | The date when the order was placed.|
| shipping_date | DATE | The date when the order was shipped to the customer.|
| due_date | DATE | The date when the order payment was due.|
| sales_amount | INTEGER | The total monetary value of the sale for the line item, in whole currency units (e.g. 90).|
| quantity | INTEGER | The number of units of the product ordered for the line item (e.g. 2).|
| price | INTEGER | The price per unit of the product for the line item, in whole currency unites (e.g. 45).|

