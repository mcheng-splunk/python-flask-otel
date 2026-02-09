# Use Python 3.11 slim (or 3.9+)
FROM python:3.11-slim

# Set workdir
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install splunk-opentelemetry

# Copy app code
COPY app/ ./app

# Expose port
EXPOSE 5000

# Command to run
CMD ["opentelemetry-instrument", "python", "app/main.py"]

