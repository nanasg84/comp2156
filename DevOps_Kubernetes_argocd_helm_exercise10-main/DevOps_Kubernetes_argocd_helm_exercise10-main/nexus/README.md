Here’s a clear, practical walkthrough to **run Nexus with Docker Compose** and **publish a Docker image for your Python project**.

---

# 1) Run Nexus with Docker Compose

Create a `docker-compose.yml`:

```yaml
version: "3.8"

services:
  nexus:
    image: sonatype/nexus3:latest
    container_name: nexus
    ports:
      - "8081:8081"   # Nexus UI
      - "5000:5000"   # Docker repo (hosted)
    volumes:
      - nexus-data:/nexus-data
    restart: unless-stopped

volumes:
  nexus-data:
```

Start it:

```bash
docker compose up -d
```

Open Nexus UI:

```
http://localhost:8081
```

---

# 2) Initial Nexus Setup

### Get admin password

```bash
docker exec nexus cat /nexus-data/admin.password
```

Login:

* Username: `admin`
* Password: (from above)

---

# 3) Create Docker Hosted Repository

In Nexus UI:

1. Go to **Settings → Repositories**
2. Click **Create repository**
3. Choose **Docker (hosted)**

Configure:

* Name: `docker-hosted`
* HTTP port: `5000`
* Enable: ✔

Save.

---

# 4) Allow Docker to Use Insecure Registry (IMPORTANT)

If you're not using HTTPS:

### Linux:

Edit `/etc/docker/daemon.json`:

```json
{
  "insecure-registries": ["localhost:5000"]
}
```

Restart Docker:

```bash
sudo systemctl restart docker
```

###  Using Docker Desktop Settings (Recommended for Windows Desktop)
This is the most straightforward method for users of Docker Desktop on Windows. 
1) Open Docker Desktop by clicking the Docker whale icon in the system tray.
2) Select Settings (or Preferences in older versions) from the menu.
3) Navigate to the Docker Engine section in the left sidebar.
4) In the JSON text area, add or update the "insecure-registries" property with your registry's address (e.g., "localhost:5000").

```json
{
  "insecure-registries": [
    "myregistry.example.com:5000"
  ],
  "registry-mirrors": []
}

```
5) Click Apply & Restart at the bottom right of the settings window to save the changes and restart the Docker daemon.


---

# 5) Python Project Dockerfile

Inside your Python project, create:

```dockerfile
# Use an official Python runtime as a parent image
FROM python:3.11-slim
# Set the working directory to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
COPY . /app
# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt
# Make port 80 available to the world outside this container
EXPOSE 80
# Define environment variable
ENV NAME=Pritesh
# Run app.py when the container launches
CMD ["python", "app.py"]
```

---

# 6) Build Docker Image

```bash
docker build -t localhost:5000/hellodocker-python-app:1.0 .
```

---

# 7) Login to Nexus Docker Registry

```bash
docker login localhost:5000
```

Use:

* Username: admin (or created user)
* Password: your Nexus password

---

# 8) Push Image to Nexus

```bash
docker push localhost:5000/hellodocker-python-app:1.0
```

---

# 9) Verify in Nexus

Go to:

* Browse → docker-hosted

You should see:

```
hellodocker-python-app:1.0
```

---

# 10) Pull Image (Test)

```bash
docker pull localhost:5000/hellodocker-python-app:1.0
```

---

# Optional (Recommended Improvements)

### ✅ Use a proper hostname instead of localhost

Example:

```
nexus.local:5000
```

### ✅ Enable HTTPS (production)

Use a reverse proxy like:

* Nginx
* Traefik

### ✅ Create a dedicated user instead of admin

---

# Common Issues

### ❌ Push fails (connection refused)

* Port 5000 not exposed
* Repo not created

### ❌ “server gave HTTP response to HTTPS client”

* You forgot insecure registry config

### ❌ Unauthorized

* Wrong credentials
* Repo permissions

---

If you want, I can also show:

* CI/CD pipeline (GitHub Actions / GitLab)
* Version tagging strategy
* Kubernetes deployment using Nexus images
