from flask import Flask, request, jsonify
import sqlite3
import time
import json
import os

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Initialize SQLite database
DB_FILE = os.path.join(BASE_DIR, 'users_data.db')
API_KEYS_FILE = os.path.join(BASE_DIR, 'allowed_api_keys.json')

def load_api_keys():
    try:
        with open(API_KEYS_FILE, 'r') as file:
            keys = json.load(file)
        print(f"Loaded API Keys: {keys}")
        # Extract API keys from the list of dictionaries
        return [key['api_key'] for key in keys if 'api_key' in key]
    except (FileNotFoundError, json.JSONDecodeError):
        return []

ALLOWED_API_KEYS = load_api_keys()

def init_db():
    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute('''CREATE TABLE IF NOT EXISTS users (
                            device_id TEXT PRIMARY KEY,
                            last_smoked TEXT,
                            cig_avoided INTEGER,
                            money_saved REAL,
                            last_announced INTEGER
                          )''')
        conn.commit()

def validate_request():
    api_key = request.headers.get('X-API-Key')
    print(f"Received API Key: {api_key}")
    print(f"Allowed Keys: {ALLOWED_API_KEYS}")

    if not api_key or api_key not in ALLOWED_API_KEYS:
        return False
    return True

@app.route('/api/sync', methods=['POST'])
def sync():
    # Validate request
    if not validate_request():
        return jsonify({"error": "Unauthorized request"}), 401

    data = request.json
    print(f"Received Data: {data}")

    # Extract data
    device_id = data.get('device_id')
    last_smoked = data.get('last_smoked')
    cig_avoided = data.get('cig_avoided', 0)
    money_saved = data.get('money_saved', 0.0)
    friends = data.get('friends', [])  
    
    # Generate current timestamp for last_announced
    last_announced = int(time.time())

    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        # Update or insert user stats
        cursor.execute('''INSERT INTO users (device_id, last_smoked, cig_avoided, money_saved, last_announced)
                          VALUES (?, ?, ?, ?, ?)
                          ON CONFLICT(device_id) DO UPDATE SET 
                          last_smoked=?, cig_avoided=?, money_saved=?, last_announced=?''',
                       (device_id, last_smoked, cig_avoided, money_saved, last_announced, last_smoked, cig_avoided, money_saved, last_announced))

        # Prepare friends' data
        friends_data = []
        for friend in friends:
            # Ensure friend is a dictionary and extract the 'uid'
            if isinstance(friend, dict) and 'uid' in friend:
                friend_id = friend['uid']
                cursor.execute('SELECT last_smoked, cig_avoided, money_saved, last_announced FROM users WHERE device_id = ?', (friend_id,))
                row = cursor.fetchone()
                if row:
                    friends_data.append({
                        "device_id": friend_id,
                        "last_smoked": row[0],
                        "cig_avoided": row[1],
                        "money_saved": row[2],
                        "last_announced": row[3]
                    })

    # Respond with friends' latest stats
    return jsonify({"friends_data": friends_data})

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000)
