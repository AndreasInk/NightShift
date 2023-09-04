# Use an official Python runtime as base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements.txt and install packages
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy current directory contents into the container at /app
COPY . .

# Set environment variable for FastAPI to run in production mode
ENV FASTAPI_ENV=production

# Expose port
EXPOSE 8080

# Run FastAPI application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
