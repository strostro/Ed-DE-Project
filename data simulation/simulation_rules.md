| Content Type | Event Types Triggered | Frequency / Quantity | Timing Logic | Notes |
| --- | --- | --- | --- | --- |
| video | `video_started`, `video_completed` | 1 start + 1 complete per video | `completed` occurs ~90–100% duration later | Add `duration` field in `video_completed` |
| slide | `slide_viewed` | 1 per slide | ~3–5 sec per slide | Use `slide_index` to simulate progression |
| article | `article_read` | 1 per article | Once `read_percent` reaches 90% | Add random `read_percent` value (e.g., 92%) |
| quiz | `quiz_opened`, `question_answered`, `question_submitted`, `quiz_completed` | 1 open + N questions + 1 completed | Answered ~5–15 sec/each; complete at the end | Random `answer_given`, correctness, `score` |
| exercise | `exercise_opened`, `question_answered`, `question_submitted`, `exercise_completed` | 1 open + N questions + 1 completed | Same as quiz | Similar structure to quiz |
| lesson | `lesson_completed` | 1 per lesson if all contents done | After all content events are triggered | Optional: track `completion_ratio` if partial |
