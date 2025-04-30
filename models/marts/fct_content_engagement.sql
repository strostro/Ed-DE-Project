{{ config(materialized='view') }}

with events as (
    select *
    from {{ ref('int_user_content_events') }}
),

aggregated as (
    select
        course_id,
        content_id,

        -- 视频指标
        count_if(event_type = 'video_started') as video_started_count,
        count_if(event_type = 'video_completed') as video_completed_count,
        sum(coalesce(duration, 0)) as total_video_duration,

        -- 阅读指标
        avg(read_percent) as avg_read_percent,

        -- 幻灯片指标
        count_if(event_type = 'slide_viewed') as slide_viewed_count,

        -- 题目指标
        count_if(event_type = 'question_submitted') as question_count,
        sum(case when correct then 1 else 0 end) as correct_count,
        round(
            100.0 * sum(case when correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0),
            2
        ) as correct_rate,

        -- 互动总数
        count(*) as total_events,

        -- 最近一次互动时间
        max(timestamp) as last_event_time

    from events
    group by course_id, content_id
)

select * from aggregated
