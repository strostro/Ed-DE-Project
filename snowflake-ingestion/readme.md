# Kafka to Snowflake Ingestion

This script consumes real-time learning event messages from a Kafka topic (`learning-events`) and writes them to a raw table in Snowflake.

## Key Components
- Kafka Consumer (Python)
- Topic: `learning-events`
- Target Table: `RAW_LEARNING_EVENTS_V2`

## How It Works
- Messages are received as JSON
- Flattened into structured rows
- Inserted into Snowflake using Snowflake Python Connector

## Requirements
- snowflake-connector-python
- Kafka-python

## Run
```bash
python_to_snowflake.py
