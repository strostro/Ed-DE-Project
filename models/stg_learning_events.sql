-- models/stg_learning_events.sql

{{ config(materialized='view') }}

SELECT
    event_id,
    event_type,
    timestamp,
    raw_payload
FROM kafka_demo.public.raw_learning_events

