# Kafka Setup (on AWS EC2 with Docker)

This setup enables real-time data streaming using Kafka, Zookeeper, and Kafka UI, all deployed via Docker on an AWS EC2 instance. It supports publishing learning behavior events from a Python-based producer.

---

## 1. Launch EC2 for Kafka

1. Create an **Ubuntu EC2 instance**
2. In **Security Group**, open port **9092** (Kafka) and **8080** (Kafka UI)
3. Connect via SSH:

```bash
ssh -i "your-key.pem" ubuntu@your-ec2-ip
```

---

## 2. Install Docker & Docker Compose

```bash
# Update sources
sudo apt update

# Install Docker and Docker Compose
sudo apt install -y docker.io docker-compose

# Start Docker and enable it on boot
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional)
sudo usermod -aG docker $USER

# Reboot or re-login to apply user group changes
```

---

## 3. Set Up Kafka with Docker Compose

1. Create a project directory:

```bash
mkdir kafka-docker
cd kafka-docker
```

2. Upload your `docker-compose.yml` to the instance:

```bash
scp -i "your-key.pem" docker-compose.yml ubuntu@your-ec2-ip:~/kafka-docker/
```

3. Run Kafka + Zookeeper + Kafka UI:

```bash
cd ~/kafka-docker
docker-compose up -d
```

4. Check containers:

```bash
docker ps
```

Kafka UI will be available at: `http://your-ec2-ip:8080`

---

## 4. Restart or Reset Kafka 

If you want to fully reset the stack (e.g. to clear volumes):

```bash
cd ~/kafka-docker
docker-compose down -v   # Removes containers and volumes
docker-compose up -d     # Recreate fresh environment
```

---

## 5. Upload Simulation Files 

```bash
# Upload Python data generator
scp -i "your-key.pem" behaviour_simulation.py ubuntu@your-ec2-ip:~/kafka-producer/

# Upload supporting course data folder
scp -r -i "your-key.pem" course_data/ ubuntu@your-ec2-ip:~/kafka-producer/

# Upload Python consumer (e.g., to send data to Snowflake)
scp -i "your-key.pem" to_snowflake.py ubuntu@your-ec2-ip:~/
```

---

## 📝 Notes

- Replace `your-ec2-ip` and `your-key.pem` with your actual IP and SSH key.

---

## 📂 Files in this folder

- `docker-compose.yml` — Kafka + Zookeeper + Kafka UI config
- `README.md` — setup and usage instructions
