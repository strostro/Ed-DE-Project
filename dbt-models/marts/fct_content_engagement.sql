{{ config(materialized='table') }}

with events as (
    select *
    from {{ ref('int_user_content_events') }}
),

aggregated as (
    select
        course_id,
        content_id,


        count_if(event_type = 'video_started') as video_started_count,
        count_if(event_type = 'video_completed') as video_completed_count,
        sum(coalesce(video_duration, 0)) as total_video_duration,
        round(
            100.0 * count_if(event_type = 'video_completed') / nullif(count_if(event_type = 'video_started'), 0),
            2
        ) as video_completion_rate,


        avg(read_percent) as avg_read_percent,

        count_if(event_type = 'slide_viewed') as slide_viewed_count,


        count_if(event_type = 'question_submitted') as question_count,
        sum(case when is_correct then 1 else 0 end) as correct_count,
        round(
            100.0 * sum(case when is_correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0),
            2
        ) as question_correct_rate,

        count(*) as total_events,
        round(
            count(*) * 1.0 / nullif(count_if(event_type = 'video_started'), 0),
            2
        ) as interaction_per_event,

    
        case when count(*) > 0 then true else false end as has_activity,

        max(timestamp) as last_event_time

    from events
    group by course_id, content_id
)

select * from aggregated
