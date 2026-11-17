from flask import Flask, jsonify
import os
app = Flask(__name__)
VERSION = os.getenv("APP_VERSION", "dev")
@app.route('/health')
def health(): return jsonify(status="ok", version=VERSION)
@app.route('/')
def home(): return f"<h1>Bienvenue</h1><p>Version {VERSION}</p>"
