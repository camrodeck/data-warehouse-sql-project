/*
=====================================================
Create Database & Schemas
=====================================================

Script Purpose:
This SQL script is used to create the 'datawarehouse' database & create our 3 schemas for the different layers in our project...

------------------------------------------------------------------------------------------------------------------------------
*/


-- Create the 'datawarehouse' database
CREATE DATABASE datawarehouse;

--Create our 3 schemas: 'bronze','silver', & 'gold'
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
