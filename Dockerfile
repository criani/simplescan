# Use an official lightweight Python image.
FROM python:3.8-slim

# Install nmap
RUN apt-get update && \
    apt-get install -y nmap
# Set environment variables.
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP main.py
ENV FLASK_RUN_HOST 0.0.0.0

# Set work directory.
WORKDIR /app

# Install dependencies.
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project.
COPY . /app/

# Expose port 5000
EXPOSE 5000

# Run the application.
CMD ["flask", "run"]
