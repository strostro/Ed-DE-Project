-- models/marts/fct_user_engagement.sql

{{ config(materialized='view') }}

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
        sum(video_duration) as total_video_duration,

        -- 阅读类指标
        avg(read_percent) as avg_read_percent,

        -- 幻灯片指标
        count_if(event_type = 'slide_viewed') as slide_view_count,

        -- 题目类指标
        count_if(event_type = 'question_submitted') as question_count,
        sum(case when is_correct then 1 else 0 end) as correct_count,
        round(100.0 * sum(case when is_correct then 1 else 0 end) / nullif(count_if(event_type = 'question_submitted'), 0), 2) as correct_rate,

        -- 总互动数
        count(*) as total_events,

        -- 最近一次行为
        max(timestamp) as last_event_time

    from events
    group by user_id, course_id
)

select * from aggregated
