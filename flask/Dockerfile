#official python image
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

# install requirements
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

#to connect port to outside 
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=app.py

CMD ["flask", "run", "--host=0.0.0.0"]