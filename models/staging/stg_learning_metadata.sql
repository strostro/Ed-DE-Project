-- models/staging/stg_learning_metadata.sql

with base as (
    select
        event_id,
        event_type,
        metadata
    from {{ ref('stg_learning_events') }}
),

flattened as (
    select
        event_id,
        event_type,

        -- 🎥 Video
        case when event_type = 'video_completed' then metadata:"duration"::float end as video_duration,

        -- 🖼️ Slide
        case when event_type = 'slide_viewed' then metadata:"slide_index"::int end as slide_index,

        -- 📖 Article
        case when event_type = 'article_read' then metadata:"read_percent"::float end as read_percent,

        -- ❓ Question
        case when event_type = 'question_submitted' then metadata:"question_id"::string end as question_id,
        case when event_type = 'question_submitted' then metadata:"answer_given"::string end as answer_given,
        case when event_type = 'question_submitted' then metadata:"correct"::boolean end as is_correct,

        -- 🧩 你可以继续添加更多字段，如 score、completion_ratio 等
        -- 来自 quiz_completed 或 exercise_completed
        case when event_type in ('quiz_completed', 'exercise_completed') then metadata:"score"::float end as score,
        case when event_type in ('quiz_completed', 'exercise_completed') then metadata:"total_questions"::int end as total_questions,

        -- 来自 lesson_completed
        case when event_type = 'lesson_completed' then metadata:"completion_ratio"::float end as completion_ratio

    from base
)

select * from flattened
