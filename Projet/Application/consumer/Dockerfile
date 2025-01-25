FROM python:3.12-slim

COPY . /app

WORKDIR /app

RUN pip install --upgrade pip \
&& pip install -r requirements.txt

LABEL app="consumer"

CMD ["python", "consumer.py"]
