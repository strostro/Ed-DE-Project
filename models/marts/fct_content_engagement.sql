{{ config(materialized='table') }}

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
        sum(coalesce(video_duration, 0)) as total_video_duration,
        round(
            100.0 * count_if(event_type = 'video_completed') / nullif(count_if(event_type = 'video_started'), 0),
            2
        ) as video_completion_rate,

        -- 阅读指标
        avg(read_percent) as avg_read_percent,

        -- 幻灯片指标
        count_if(event_type = 'slide_viewed') as slide_viewed_count,

        -- 题目指标
        count_if(event_type = 'question_submitted') as question_count,
        sum(case when is_correct then 1 else 0 end) as correct_count,
        round(
            100.0 * sum(case when is_correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0),
            2
        ) as question_correct_rate,

        -- 总互动量与平均每内容互动
        count(*) as total_events,
        round(
            count(*) * 1.0 / nullif(count_if(event_type = 'video_started'), 0),
            2
        ) as interaction_per_event,

        -- 是否有行为（用于后续筛选内容是否活跃）
        case when count(*) > 0 then true else false end as has_activity,

        -- 最近一次互动时间
        max(timestamp) as last_event_time

    from events
    group by course_id, content_id
)

select * from aggregated
