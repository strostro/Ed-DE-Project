-- models/staging/stg_learning_events.sql

with source as (

    select
        event_id,
        event_type,
        timestamp,
        -- 用 parse_json 函数解析 raw_payload 字段
        parse_json(raw_payload) as payload

    from {{ source('kafka_demo', 'raw_learning_events') }}

),

flattened as (

    select
        event_id,
        event_type,
        timestamp,
        payload:"user_id"::string as user_id,
        payload:"course_id"::string as course_id,
        payload:"lesson_id"::string as lesson_id,
        payload:"content_id"::string as content_id,
        payload:"question_id"::string as question_id,
        payload:"duration"::float as duration,
        payload:"read_percent"::float as read_percent,
        payload:"slide_index"::int as slide_index,
        payload:"answer_given"::string as answer_given,
        payload:"correct"::boolean as correct,
        payload:"score"::float as score,
        payload:"total_questions"::int as total_questions,
        payload:"completion_ratio"::float as completion_ratio,
        payload:"metadata"::variant as metadata

    from source

)

select * from flattened

