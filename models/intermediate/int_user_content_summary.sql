-- models/intermediate/int_user_content_summary.sql

with events as (
    select *
    from {{ ref('int_user_content_events') }}
)

select
    user_id,
    course_id,
    content_id,
    max(case when event_type = 'video_started' then 1 else 0 end) as video_started,
    max(case when event_type = 'video_completed' then 1 else 0 end) as video_completed,
    max(score) as score,
    max(total_questions) as total_questions,
    max(completion_ratio) as completion_ratio
from events
group by user_id, course_id, content_id
