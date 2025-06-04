{{ config(materialized='table') }}

with events as (
    select *
    from {{ ref('int_user_content_events') }}
),

aggregated as (
    select
        user_id,
        course_id,
        content_id,

        max(case when event_type = 'video_completed' then 1 else 0 end) as video_completed,

        max(case when read_percent >= 0.8 then 1 else 0 end) as article_read_completed,

        max(case when event_type = 'slide_viewed' then 1 else 0 end) as slide_viewed,

        max(case when event_type = 'question_submitted' then 1 else 0 end) as question_answered,

        case
            when
                max(case when event_type in (
                    'video_completed', 'article_read', 'slide_viewed', 'question_submitted'
                ) then 1 else 0 end) = 1
            then 1
            else 0
        end as is_content_completed

    from events
    group by user_id, course_id, content_id
)

select * from aggregated
