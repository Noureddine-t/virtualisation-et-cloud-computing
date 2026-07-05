from flask import Flask
from flask_cors import CORS
import pika
import redis
import json
import os
import sys

app = Flask(__name__)
CORS(app)

# Connection to RabbitMQ
connection = pika.BlockingConnection(pika.ConnectionParameters('svc-rabbitmq', heartbeat=0))
channel = connection.channel()
channel.queue_declare(queue='calculation_queue')

redis_client = redis.Redis(host='svc-redis', port=6379, db=0)


def callback(ch, method, properties, body):
    print(f" [x] Received {body}")

    data = json.loads(body)
    num1 = data.get('num1')
    num2 = data.get('num2')
    operator = data.get('operator')
    calc_id = data.get('calc_id')

    # Perform the calculation
    try:
        if operator == 'add':
            result = num1 + num2
        elif operator == 'subtract':
            result = num1 - num2
        elif operator == 'multiply':
            result = num1 * num2
        elif operator == 'divide':
            if num2 == 0:
                raise ValueError("Dividing by zero is not allowed")
            result = num1 / num2
        else:
            raise ValueError("Unvalid operator")
    except Exception as e:
        print(f"Erreur : {e}")
        result = None

    # Set the result in Redis
    if result is not None:
        redis_client.set(calc_id, result)

channel.basic_consume(queue='calculation_queue', on_message_callback=callback, auto_ack=True)
print(' [*] Waiting for messages. To exit press CTRL+C')
channel.start_consuming()

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    except KeyboardInterrupt:
        print('Interrupted')
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)
