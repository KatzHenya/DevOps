import os
import json
from datetime import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # מאפשר בקשות מה-Frontend ב-Cloud Run

# Configurable database file path
DB_PATH = os.getenv("DB_PATH", os.path.join(os.path.dirname(__file__), "database", "db.json"))


def load_db():
    """Load tasks from JSON file."""
    if not os.path.exists(DB_PATH):
        os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
        default_data = [
            {
                "id": 1,
                "title": "Configure GitHub Repository",
                "status": "Completed",
                "assigned_to": "Student A",
                "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M")
            },
            {
                "id": 2,
                "title": "Write Dockerfile (Multi-stage)",
                "status": "In Progress",
                "assigned_to": "Student B",
                "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M")
            }
        ]
        with open(DB_PATH, 'w', encoding='utf-8') as f:
            json.dump(default_data, f, indent=2, ensure_ascii=False)
        return default_data
    try:
        with open(DB_PATH, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        app.logger.error(f"Error loading database: {e}")
        return []


def save_db(data):
    """Save tasks to JSON file."""
    try:
        os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
        with open(DB_PATH, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        app.logger.error(f"Error saving database: {e}")
        return False


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({"status": "ok"}), 200


@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks."""
    return jsonify(load_db())


@app.route('/api/tasks', methods=['POST'])
def add_task():
    """Add a new task."""
    data = request.json or {}
    title = data.get("title")
    assigned_to = data.get("assigned_to", "Unassigned")
    status = data.get("status", "Pending")

    if not title:
        return jsonify({"error": "Title is required"}), 400

    tasks = load_db()
    new_id = max([t.get("id", 0) for t in tasks] + [0]) + 1

    new_task = {
        "id": new_id,
        "title": title,
        "status": status,
        "assigned_to": assigned_to,
        "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M")
    }

    tasks.append(new_task)
    if save_db(tasks):
        return jsonify(new_task), 201
    return jsonify({"error": "Failed to save data"}), 500


@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task."""
    tasks = load_db()
    updated_tasks = [t for t in tasks if t.get("id") != task_id]

    if len(tasks) == len(updated_tasks):
        return jsonify({"error": "Task not found"}), 404

    if save_db(updated_tasks):
        return jsonify({"message": f"Task {task_id} deleted successfully"}), 200
    return jsonify({"error": "Failed to save data"}), 500


@app.route('/api/tasks/<int:task_id>/status', methods=['POST'])
def update_status(task_id):
    """Update task status."""
    data = request.json or {}
    new_status = data.get("status")

    if not new_status:
        return jsonify({"error": "Status is required"}), 400

    tasks = load_db()
    found = False
    for task in tasks:
        if task.get("id") == task_id:
            task["status"] = new_status
            task["updated_at"] = datetime.now().strftime("%Y-%m-%d %H:%M")
            found = True
            break

    if not found:
        return jsonify({"error": "Task not found"}), 404

    if save_db(tasks):
        return jsonify({"message": f"Task {task_id} status updated to {new_status}"}), 200
    return jsonify({"error": "Failed to save data"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
