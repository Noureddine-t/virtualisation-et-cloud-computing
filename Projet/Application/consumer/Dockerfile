FROM python:3.12-slim

COPY . /app

WORKDIR /app

RUN pip install flask
RUN pip install redis
RUN python -m pip install pika --upgrade
RUN pip install -U flask-cors

LABEL app="consumer"

CMD ["python", "consumer.py"]
