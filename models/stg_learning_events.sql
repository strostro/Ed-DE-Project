-- models/stg_learning_events.sql

{{ config(materialized='view') }}

SELECT
    raw_payload
FROM kafka_demo.public.raw_learning_events

