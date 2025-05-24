{{ config(materialized='table') }}

with events as (
    select *
    from {{ ref('int_user_content_events') }}
),

aggregated as (
    select
        user_id,
        course_id,

        -- 视频类指标
        count_if(event_type = 'video_started') as video_start_count,
        count_if(event_type = 'video_completed') as video_complete_count,
        sum(coalesce(video_duration, 0)) as total_video_duration,

        -- 阅读类指标
        avg(read_percent) as avg_read_percent,

        -- 幻灯片指标
        count_if(event_type = 'slide_viewed') as slide_view_count,

        -- 题目类指标
        count_if(event_type = 'question_submitted') as question_count,
        sum(case when is_correct then 1 else 0 end) as correct_count,
        round(
            100.0 * sum(case when is_correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0),
            2
        ) as correct_rate,

        -- 总互动数
        count(*) as total_events,

        -- 最近一次行为
        max(timestamp) as last_event_time,

        -- 🎯 用户分层标签
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
