{{ config(materialized='table') }}

with events as (
    select *
    from {{ ref('int_user_content_events') }}
),

aggregated as (
    select
        user_id,
        course_id,

        count_if(event_type = 'video_started') as video_start_count,
        count_if(event_type = 'video_completed') as video_complete_count,
        sum(coalesce(video_duration, 0)) as total_video_duration,

        avg(read_percent) as avg_read_percent,


        count_if(event_type = 'slide_viewed') as slide_view_count,

        count_if(event_type = 'question_submitted') as question_count,
        sum(case when is_correct then 1 else 0 end) as correct_count,
        round(
            100.0 * sum(case when is_correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0),
            2
        ) as correct_rate,

        count(*) as total_events,

        max(timestamp) as last_event_time,

        case
            when max(timestamp) >= current_date - 7
                 and count_if(event_type = 'video_completed') >= 3
                 and round(
                     100.0 * sum(case when is_correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0),
                     2
                 ) >= 70
                then 'Active_Engaged'

            when max(timestamp) >= current_date - 7
                 and count_if(event_type = 'video_completed') > 0
                 and count_if(event_type = 'question_submitted') = 0
                then 'Passive_Watcher'

            when round(
                     100.0 * sum(case when is_correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0),
                     2
                 ) < 50
                 and count_if(event_type = 'question_submitted') >= 3
                then 'Low_Performance'

            when max(timestamp) < current_date - 14
                then 'Inactive'

            else 'Uncategorized'
        end as user_segment

    from events
    group by user_id, course_id
)

select * from aggregated
