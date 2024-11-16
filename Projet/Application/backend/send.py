import json
from flask import Flask, request, jsonify
import redis
import uuid
from flask_cors import CORS
import pika

app = Flask(__name__)
CORS(app)

# Connection to RabbitMQ
connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()

channel.queue_declare(queue='calculation_queue')

"""End point to send a calculation to the consumer"""


@app.route('/api/calculate', methods=['POST'])
def calculate():
    data = request.get_json()
    num1 = data.get('num1')
    num2 = data.get('num2')
    operator = data.get('operator')

    if not all([num1, num2, operator]):
        return jsonify({"error": "Veuillez fournir deux nombres et un opérateur"}), 400

    calc_id = str(uuid.uuid4())

    message = {
        "num1": num1,
        "num2": num2,
        "operator": operator,
        "calc_id": calc_id
    }
    channel.basic_publish(exchange='', routing_key='calculation_queue', body=json.dumps(message))
    print(" [x] Sent 'Calculation data'")
    connection.close()

    return jsonify({"id": calc_id}), 200


# Connection to Redis
redis_client = redis.Redis(host='localhost', port=6379, db=0)

"""endpoint to get the result of a calculation from redis using its ID"""


@app.route('/api/result/<calc_id>', methods=['GET'])
def get_result(calc_id):
    result = redis_client.get(calc_id)
    if result is None:
        return jsonify({"error": "Résultat non trouvé"}), 404
    return jsonify({"id": calc_id, "result": float(result)}), 200


if __name__ == '__main__':
    app.run(debug=True)
