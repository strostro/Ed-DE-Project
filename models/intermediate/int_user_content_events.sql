-- models/intermediate/int_user_content_events.sql

with base as (
    select * 
    from {{ ref('stg_learning_events') }}
),

meta as (
    select * 
    from {{ ref('stg_learning_metadata') }}
),

joined as (
    select
        base.user_id,
        base.course_id,
        base.content_id,
        base.lesson_id,
        base.event_type,
        base.timestamp,
        meta.video_duration,
        meta.read_percent,
        meta.slide_index,
        meta.question_id,
        meta.answer_given,
        meta.is_correct,
        meta.score,
        meta.total_questions,
        meta.completion_ratio
    from base
    left join meta using (event_id)
),

pivoted as (
    select
        user_id,
        course_id,
        content_id,
        lesson_id,
        max(case when event_type = 'video_started' then 1 else 0 end) as video_started,
        max(case when event_type = 'video_completed' then 1 else 0 end) as video_completed,
        max(video_duration) as duration,
        max(read_percent) as read_percent,
        max(slide_index) as slide_index,
        max(score) as score,
        max(total_questions) as total_questions,
        max(completion_ratio) as completion_ratio
    from joined
    group by user_id, course_id, content_id, lesson_id
)

select * from pivoted
