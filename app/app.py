from flask import Flask, jsonify
import os
import logging

app = Flask(__name__)
logger = logging.getLogger(__name__)

@app.route("/")
def home():
    return jsonify({
        "message": "Hello, this is a message from your Python app!",
        "status": "healthy",
        "version": os.getenv("APP_VERSION", "1.0.0")
    })

@app.route("/config")
def config():
    api_base_url = os.getenv("API_BASE_URL", "not configured")
    log_level = os.getenv("LOG_LEVEL", "INFO")
    max_connections = os.getenv("MAX_CONNECTIONS", "10")
    
    secret_configured = "Yes" if os.getenv("SECRET_KEY") else "No"
    db_configured = "Yes" if os.getenv("DB_PASSWORD") else "No"
     
    return jsonify({
        "message": "Configuration values (secrets excluded for security)",
        "config": {
            "API_BASE_URL": api_base_url,
            "LOG_LEVEL": log_level,
            "MAX_CONNECTIONS": max_connections
        },
        "secrets_status": {
            "SECRET_KEY": secret_configured,
            "DB_PASSWORD": db_configured
        }
    })

@app.route('/health')
@app.route('/health-check')
def health_check():
    return jsonify({"status": "healthy"}), 200

@app.route('/ready')
def readiness_check():
    return jsonify({"status": "ready"}), 200

if __name__ == "__main__":
    logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
    app.run(host="0.0.0.0", port=5000)