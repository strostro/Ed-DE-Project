| Event | Level | When Triggered | Key Fields |
| --- | --- | --- | --- |
| `video_started` | content | On video play | `user_id`, `timestamp`, `content_id` |
| `video_completed` | content | When video finishes | `user_id`, `timestamp`, `content_id`, `duration` |
| `slide_viewed` | content | On opening slide | `user_id`, `timestamp`, `content_id`, `slide_index` |
| `article_read` | content | Scroll reaches 90% | `user_id`, `timestamp`, `content_id`, `read_percent` |
| `quiz_opened` | content | On quiz open | `user_id`, `timestamp`, `content_id` |
| `exercise_opened` | content | On exercise open | `user_id`, `timestamp`, `content_id` |
| `question_answered` | question | Each question answered | `user_id`, `timestamp`, `content_id`, `question_id`, `answer_given`, `time_spent` |
| `question_submitted` | question | On submit question | `user_id`, `timestamp`, `content_id`, `question_id`, `answer_given`, `correct` |
| `quiz_completed` | content | All quiz questions done | `user_id`, `timestamp`, `content_id`, `score`, `total_questions` |
| `exercise_completed` | content | All exercises done | `user_id`, `timestamp`, `content_id`, `score`, `total_questions` |
| `lesson_completed` | lesson | All contents in lesson done | `user_id`, `timestamp`, `lesson_id`, `completion_ratio` |
