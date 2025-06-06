-- models/intermediate/int_user_content_events.sql

with base as (
    select *
    from {{ ref('stg_learning_events') }}
),

metadata_fields as (
    select *
    from {{ ref('stg_learning_metadata') }}
),

joined as (
    select
        base.event_id,
        base.event_type,
        base.timestamp,
        base.user_id,
        base.course_id,
        base.lesson_id,
        base.content_id,

        metadata_fields.video_duration,
        metadata_fields.read_percent,
        metadata_fields.slide_index,
        metadata_fields.question_id,
        metadata_fields.answer_given,
        metadata_fields.is_correct,
        metadata_fields.score,
        metadata_fields.total_questions,
        metadata_fields.completion_ratio

    from base
    left join metadata_fields
        on base.event_id = metadata_fields.event_id
)

select * from joined
