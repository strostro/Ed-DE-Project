-- models/marts/fct_user_event_timeline.sql

{{ config(materialized='view') }}

with events as (
    select
        user_id,
        course_id,
        lesson_id,
        content_id,
        event_type,
        timestamp,
        video_duration,
        read_percent,
        slide_index,
        question_id,
        answer_given,
        is_correct,
        score,
        total_questions,
        completion_ratio
    from {{ ref('int_user_content_events') }}
)

select * from events
order by user_id, timestamp
