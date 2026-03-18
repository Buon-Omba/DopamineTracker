import json
import uuid
import datetime

API_KEYS_FILE = 'allowed_api_keys.json'

# Load existing keys
def load_api_keys():
    try:
        with open(API_KEYS_FILE, 'r') as file:
            return json.load(file)
    except (FileNotFoundError, json.JSONDecodeError):
        return []

# Save keys to file
def save_api_keys(keys):
    with open(API_KEYS_FILE, 'w') as file:
        json.dump(keys, file, indent=4)

# Generate new API key
def generate_api_key(version, date):
    keys = load_api_keys()

    # Create new key
    new_key = {
        "version": version,
        "api_key": str(uuid.uuid4()),
        "date": date
    }

    # Add key and save
    keys.append(new_key)
    save_api_keys(keys)
    print("New API key added:", new_key)

# Delete API key by version
def delete_api_key(version):
    keys = load_api_keys()
    keys = [key for key in keys if key['version'] != version]
    save_api_keys(keys)
    print(f"API key for version {version} has been deleted.")

if __name__ == '__main__':
    action = input("Choose action: [1] Generate API Key, [2] Delete API Key: ")

    if action == '1':
        version = input("Enter version number (e.g., v1.0.0): ")
        date = input("Enter release date (YYYY-MM-DD): ")

        # Validate date
        try:
            datetime.datetime.strptime(date, '%Y-%m-%d')
        except ValueError:
            print("Invalid date format. Use YYYY-MM-DD.")
            exit(1)

        generate_api_key(version, date)

    elif action == '2':
        version = input("Enter version number to delete (e.g., v1.0.0): ")
        delete_api_key(version)

    else:
        print("Invalid action.")
