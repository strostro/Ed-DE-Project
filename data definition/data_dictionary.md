| Field | Type | Required | Example | Description |
| --- | --- | --- | --- | --- |
| `event` | string | Yes | `"question_submitted"` | Type of user behavior |
| `user_id` | string | Yes | `"U001"` | Unique user identifier |
| `timestamp` | datetime | Yes | `"2025-04-16T09:00:00Z"` | ISO 8601 format |
| `content_id` | string | Yes | `"QZ001"` | Content item ID |
| `question_id` | string | No | `"QZ001_Q2"` | Question ID (if applicable) |
| `answer_given` | string | No | `"5"` | Answer input by the user |
| `correct` | boolean | No | `true` | Whether the answer was correct |
| `lesson_id` | string | No | `"U1_L1"` | For lesson-level events |
