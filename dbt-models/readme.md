# dbt Models (Snowflake)

This folder contains dbt models for transforming raw Kafka event data into clean, analysis-ready tables in Snowflake.

## Layered Model Structure

- **stg_***: Clean and rename raw data fields  
- **int_***: Intermediate business logic 
- **fct_***: Final fact tables used in dashboards

