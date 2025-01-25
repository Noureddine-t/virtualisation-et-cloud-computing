FROM python:3.12-slim

COPY . /app

WORKDIR /app

RUN pip install --upgrade pip \
&& pip install -r requirements.txt

LABEL app="backend-api"

EXPOSE 5000

CMD ["python", "send.py"]
