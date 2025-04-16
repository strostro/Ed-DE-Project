import os
import csv
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

# ========== Configurations ==========

# 4 categories and their URLs
categories = {
    "math": "https://outschool.com/search?theme=math",
    "science-and-nature": "https://outschool.com/search?theme=science-and-nature",
    "coding-and-tech": "https://outschool.com/search?theme=coding-and-tech",
    "games-and-hobbies": "https://outschool.com/search?theme=games-and-hobbies"
}

# Output CSV file path
OUTPUT_CSV = r"D:\XIE YUE\ONEDRIVE\data engineer project\all_courses.csv"

SCROLL_PAUSE_TIME = 2      # Time to wait after each scroll (in seconds)
MAX_NO_NEW_BATCH = 5       # Max consecutive scrolls without new data before stopping

# ========== Load existing URLs to avoid duplicates ==========

seen_courses = set()
if os.path.exists(OUTPUT_CSV):
    with open(OUTPUT_CSV, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get("url"):
                seen_courses.add(row["url"])
    print(f"{len(seen_courses)} existing course records loaded to avoid duplication.")
else:
    print("CSV file does not exist. It will be created.")

# ========== Initialize Chrome WebDriver ==========

options = Options()
options.add_argument("--headless=new")
options.add_argument("--disable-gpu")
options.add_argument("--window-size=1920,1080")
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# ========== Helper Functions ==========

def format_age(age_text):
    """Format age range to prevent Excel from auto-converting it."""
    if age_text and not age_text.startswith("'"):
        return "'" + age_text
    return age_text

def extract_course_data(card, category):
    """Extract data from a single course card with error handling."""
    try:
        title = card.find_element(By.CSS_SELECTOR, "h6").text.strip()
    except:
        title = ""
    try:
        teacher = card.find_element(By.CSS_SELECTOR, ".outschool-1aunlny").text.strip()
    except:
        teacher = ""
    try:
        rating = card.find_element(By.CSS_SELECTOR, ".outschool-1atkkdo").text.strip()
    except:
        rating = ""
    try:
        reviews = card.find_element(By.CSS_SELECTOR, ".outschool-e3cjto").text.strip().strip("() ")
    except:
        reviews = ""
    try:
        price = card.find_element(By.CSS_SELECTOR, ".outschool-1giuvzi").text.strip()
    except:
        price = ""
    try:
        schedule = card.find_element(By.CSS_SELECTOR, ".outschool-y0rm61").text.strip()
    except:
        schedule = ""
    try:
        age_elems = card.find_elements(By.CSS_SELECTOR, ".outschool-1mrp43a")
        age = age_elems[-1].text.strip() if age_elems else ""
        age = format_age(age)
    except:
        age = ""
    try:
        relative_url = card.get_attribute("href")
        link = relative_url if relative_url.startswith("http") else f"https://outschool.com{relative_url}"
    except:
        link = ""

    return {
        "category": category,
        "title": title,
        "teacher": teacher,
        "rating": rating,
        "reviews": reviews,
        "price": price,
        "schedule": schedule,
        "age_range": age,
        "url": link
    }

def save_data_to_csv(data_batch, csv_path):
    """Append a batch of course data to CSV file. Create file if it doesn't exist."""
    file_exists = os.path.isfile(csv_path)
    fieldnames = ["category", "title", "teacher", "rating", "reviews", "price", "schedule", "age_range", "url"]
    with open(csv_path, mode="a", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerows(data_batch)
    print(f"✅ Saved {len(data_batch)} new records to {csv_path}")

# ========== Scrolling and Extraction ==========

def scroll_and_extract(category, url):
    """Scroll and extract course data from a category page."""
    driver.get(url)
    time.sleep(3)

    try:
        scroll_container = driver.find_element(By.CSS_SELECTOR, "div.outschool-3rfphh")
        print(f"[{category}] Found scroll container: div.outschool-3rfphh")
    except:
        scroll_container = None
        print(f"[{category}] No scroll container found. Using window scrolling.")

    consecutive_no_new = 0
    new_count = 0

    while consecutive_no_new < MAX_NO_NEW_BATCH:
        if scroll_container:
            driver.execute_script("arguments[0].scrollTo(0, arguments[0].scrollHeight);", scroll_container)
        else:
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(SCROLL_PAUSE_TIME)

        cards = driver.find_elements(By.CSS_SELECTOR, "a[eventname='Activity Impression Click']")
        print(f"[{category}] Total course cards found: {len(cards)}")

        new_batch = []
        for card in cards:
            try:
                course_url = card.get_attribute("href")
                if course_url and course_url not in seen_courses:
                    seen_courses.add(course_url)
                    new_batch.append(extract_course_data(card, category))
            except Exception as e:
                print(f"[{category}] ⚠️ Error processing a card: {e}")
                continue

        if new_batch:
            save_data_to_csv(new_batch, OUTPUT_CSV)
            new_count += len(new_batch)
            consecutive_no_new = 0
        else:
            consecutive_no_new += 1
            print(f"[{category}] ⚠️ No new courses in this round. Consecutive empty rounds: {consecutive_no_new}")

    print(f"[{category}] Done. {new_count} new records scraped.")
    return new_count

# ========== Run Scraping for All Categories ==========

total_new_records = 0
for category, url in categories.items():
    print(f"\n========== Starting category: {category} ==========")
    total_new_records += scroll_and_extract(category, url)

print(f"\n✅ Scraping completed. Total new records added: {total_new_records}")
driver.quit()
