-- models/stg_learning_events.sql

SELECT
    raw_payload:"event_id"::STRING AS event_id,
    raw_payload:"event_type"::STRING AS event_type,
    raw_payload:"timestamp"::TIMESTAMP_LTZ AS event_timestamp,
    raw_payload:"user_id"::STRING AS user_id,
    raw_payload:"course_id"::STRING AS course_id,
    raw_payload:"lesson_id"::STRING AS lesson_id
FROM {{ ref('raw_learning_events') }}
