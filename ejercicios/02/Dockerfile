# Pull python image
FROM python:3.9-slim

# Set app working directory 
WORKDIR /app

# Copy files to docker container
COPY app.py /app
COPY requirements.txt /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000
EXPOSE 5000

# app exec args
CMD ["python", "app.py"]
