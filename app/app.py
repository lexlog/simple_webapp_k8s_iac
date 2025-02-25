from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, this is a message from your Python app!"

@app.route("/config")
def config():
    secret_key = os.getenv("SECRET_KEY")
    db_password = os.getenv("DB_PASSWORD")

    api_base_url = os.getenv("API_BASE_URL")
    log_level = os.getenv("LOG_LEVEL")
    max_connections = os.getenv("MAX_CONNECTIONS")
     
    return jsonify({
        "message": "Config and secrets accessed",
        "SECRET_KEY": secret_key,
        "DB_PASSWORD": db_password,
        "API_BASE_URL": api_base_url,
        "LOG_LEVEL": log_level,
        "MAX_CONNECTIONS": max_connections
    })

@app.route('/health-check')
def health_check():
	return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)