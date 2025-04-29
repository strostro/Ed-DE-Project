-- models/stg_learning_events.sql

{{ config(materialized='view') }}

SELECT
    event_id,
    event_type,
    timestamp,
    raw_payload
FROM KAFKA_DEMO.RAW.RAW_LEARNING_EVENTS
