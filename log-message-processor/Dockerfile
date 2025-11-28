FROM python:3.8

WORKDIR /app

RUN apt-get update && \
    apt-get install -y gcc python3-dev build-essential && \
    apt-get clean

COPY log-message-processor/requirements.txt .
RUN pip install -r requirements.txt

COPY log-message-processor/ .

EXPOSE 5000

CMD ["python", "main.py"]