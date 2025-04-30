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

        -- 关联 metadata 展开字段
        metadata_fields.duration,
        metadata_fields.read_percent,
        metadata_fields.slide_index,
        metadata_fields.question_id,
        metadata_fields.answer_given,
        metadata_fields.correct

    from base
    left join metadata_fields
        on base.event_id = metadata_fields.event_id
)

select * from joined
