# Base: Python
FROM python:3.8-slim

# CONFIGURATION
WORKDIR /app
COPY requirements.txt .

# PACKAGE INSTALL
RUN pip install --no-cache-dir -r requirements.txt

# ENV MOTE TO WORKDIR
COPY web_app /app

# Open PORT for Flask
EXPOSE 5000

# Execute Flask
CMD ["python", "app.py"]

# docker build -t soo-portfolio-image .
# docker run -d -p 5000:5000 
#    --name soo-portfolio-container soo-portfolio-image