from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/quote', methods=['GET'])
def get_quote():
    quote = "There's no such thing as a bad day when you're fishing"
    return jsonify({'quote': quote})

if __name__ == '__main__':
    app.run(debug=True)
