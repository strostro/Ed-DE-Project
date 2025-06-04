import json
import random
import time
from datetime import datetime, timedelta
import pandas as pd
from faker import Faker
from kafka import KafkaProducer

# ====== Kafka Producer 初始化 ======
producer = KafkaProducer(
    bootstrap_servers='3.25.71.43:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# ====== 加载数据文件 ======
students_df = pd.read_csv("course_data/students_list.csv")
enrollments_df = pd.read_csv("course_data/enrollments.csv")

with open("course_data/course_structure.json", "r", encoding="utf-8") as f:
    course_structure = json.load(f)

fake = Faker()
random.seed(42)

# ====== 提取课程内容序列 ======
content_sequence = []
for unit in course_structure["units"]:
    for lesson in unit["lessons"]:
        for content in lesson["contents"]:
            content_sequence.append({
                "unit_id": unit["unit_id"],
                "lesson_id": lesson["lesson_id"],
                **content
            })

# ====== 学习完成度策略 ======
def assign_completion_level():
    r = random.random()
    if r < 0.8:
        return 1.0
    elif r < 0.9:
        return random.uniform(0.5, 0.9)
    else:
        return random.uniform(0.2, 0.45)

def assign_unit_progression():
    r = random.random()
    if r < 0.05:
        return "full"
    elif r < 0.15:
        return "unit1"
    else:
        return "partial"

# ====== Kafka 发送事件 ======
def send_event(event):
    producer.send("learning-events", value=event)
    print(f"📤 Sent: {event['event_type']} | ID: {event['event_id']} | user: {event['user_id']} | content: {event['content_id']}")
    time.sleep(0.2)

# ====== 模拟内容交互行为 ======
def simulate_events(user_id, course_id, content, base_time):
    content_id = content["content_id"]
    content_type = content["type"]
    unit_id = content["unit_id"]
    lesson_id = content["lesson_id"]
    timestamp = base_time + timedelta(seconds=random.randint(1, 60))
    event_id_prefix = f"{user_id}_{content_id}"

    def create_event(event_type, extra_meta=None):
        return {
            "event_id": f"{event_id_prefix}_{event_type}_{random.randint(1000,9999)}",
            "user_id": user_id,
            "course_id": course_id,
            "unit_id": unit_id,
            "lesson_id": lesson_id,
            "content_id": content_id,
            "content_type": content_type,
            "event_type": event_type,
            "timestamp": timestamp.isoformat(),
            "metadata": extra_meta or {}
        }

    if content_type == "video":
        send_event(create_event("video_started"))
        send_event(create_event("video_completed", {"duration": random.randint(60, 300)}))

    elif content_type == "slide":
        send_event(create_event("slide_viewed", {"slide_index": random.randint(1, 10)}))

    elif content_type == "article":
        send_event(create_event("article_read", {"read_percent": random.randint(90, 100)}))

    elif content_type in ["quiz", "exercise"]:
        send_event(create_event(f"{content_type}_opened"))
        for q in content.get("questions", []):
            qid = q["question_id"]
            answer = random.choice(q.get("choices", [q["answer"]])) if "choices" in q else q["answer"]
            correct = answer == q["answer"]

            send_event(create_event("question_answered", {
                "question_id": qid,
                "answer_given": answer
            }))
            send_event(create_event("question_submitted", {
                "question_id": qid,
                "answer_given": answer,
                "correct": correct
            }))
        send_event(create_event(f"{content_type}_completed"))


# ====== 遍历 PY101 报名学生并发送行为事件 ======
py_enrollments = enrollments_df[enrollments_df['course_id'] == "PY101"]

for _, row in py_enrollments.iterrows():
    user_id = row["user_id"]
    completion_ratio = assign_completion_level()
    unit_progression = assign_unit_progression()

    if unit_progression == "full":
        max_index = len(content_sequence)
    elif unit_progression == "unit1":
        max_index = next(i for i, c in enumerate(content_sequence) if c["unit_id"] == "U2")
    else:
        max_index = random.randint(5, len(content_sequence) - 1)

    content_count = int(max_index * completion_ratio)
    selected_contents = content_sequence[:content_count]

    base_time = datetime.now() - timedelta(days=random.randint(1, 60))
    for content in selected_contents:
        simulate_events(user_id, "PY101", content, base_time)
        base_time += timedelta(minutes=random.randint(2, 10))

producer.flush()
print("✅ All events sent to Kafka!")
