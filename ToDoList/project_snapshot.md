# Project Snapshot

This file contains a snapshot of the project files.

## `app.py`

```python
from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# In-memory database (a list of dictionaries)
tasks = [
    {'id': 1, 'title': 'Learn Flask', 'done': True},
    {'id': 2, 'title': 'Build a To-Do App', 'done': False}
]
task_id_counter = len(tasks) + 1

@app.route('/')
def index():
    return render_template('index.html', tasks=tasks)

@app.route('/add', methods=['POST'])
def add():
    global task_id_counter
    title = request.form.get('title')
    if title:
        tasks.append({'id': task_id_counter, 'title': title, 'done': False})
        task_id_counter += 1
    return redirect(url_for('index'))

@app.route('/complete/<int:task_id>')
def complete(task_id):
    for task in tasks:
        if task['id'] == task_id:
            task['done'] = not task['done']
            break
    return redirect(url_for('index'))

@app.route('/delete/<int:task_id>')
def delete(task_id):
    global tasks
    tasks = [task for task in tasks if task['id'] != task_id]
    return redirect(url_for('index'))

@app.route('/edit/<int:task_id>', methods=['GET', 'POST'])
def edit(task_id):
    task = next((task for task in tasks if task['id'] == task_id), None)
    if task is None:
        return redirect(url_for('index'))

    if request.method == 'POST':
        new_title = request.form.get('title')
        if new_title:
            task['title'] = new_title
        return redirect(url_for('index'))

    return render_template('edit.html', task=task)

if __name__ == '__main__':
    app.run(debug=True)
```

## `static/style.css`

```css
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    background-color: #f4f7f6;
    color: #333;
    margin: 0;
    padding: 20px;
    display: flex;
    justify-content: center;
}

.container {
    width: 100%;
    max-width: 600px;
    background-color: #fff;
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

h1 {
    text-align: center;
    color: #2c3e50;
    margin-bottom: 20px;
}

h2 {
    color: #34495e;
    border-bottom: 2px solid #ecf0f1;
    padding-bottom: 10px;
    margin-top: 30px;
}

.add-form {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
}

.add-form input[type="text"] {
    flex-grow: 1;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 16px;
}

.add-form button {
    padding: 10px 20px;
    border: none;
    background-color: #3498db;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
    transition: background-color 0.3s;
}

.add-form button:hover {
    background-color: #2980b9;
}

.task-list {
    list-style: none;
    padding: 0;
}

.task-list li {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 5px;
    border-bottom: 1px solid #ecf0f1;
    transition: background-color 0.2s;
}

.task-list li:last-child {
    border-bottom: none;
}

.task-list li.done span {
    text-decoration: line-through;
    color: #95a5a6;
}

.task-list li .actions {
    display: flex;
    gap: 10px;
}

.actions a {
    text-decoration: none;
    padding: 5px 10px;
    border-radius: 4px;
    color: white;
    font-size: 12px;
    transition: opacity 0.3s;
}

.actions a:hover {
    opacity: 0.8;
}

.complete-btn { background-color: #2ecc71; }
.uncomplete-btn { background-color: #f1c40f; }
.delete-btn { background-color: #e74c3c; }
.edit-btn { background-color: #3498db; }

.back-link {
    display: inline-block;
    margin-top: 20px;
    text-decoration: none;
    color: #3498db;
}

.back-link:hover {
    text-decoration: underline;
}
```

## `templates/edit.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Task</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <div class="container">
        <h1>Edit Task</h1>
        <form action="{{ url_for('edit', task_id=task.id) }}" method="POST" class="add-form">
            <input type="text" name="title" value="{{ task.title }}" required>
            <button type="submit">Update</button>
        </form>
        <a href="{{ url_for('index') }}" class="back-link">Back to List</a>
    </div>
</body>
</html>
```

## `templates/index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>To-Do List</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <div class="container">
        <h1>My To-Do List</h1>
        <form action="{{ url_for('add') }}" method="POST" class="add-form">
            <input type="text" name="title" placeholder="Enter a new task" required>
            <button type="submit">Add</button>
        </form>

        <h2>Pending</h2>
        <ul class="task-list">
            {% for task in tasks if not task.done %}
                <li>
                    <span>{{ task.title }}</span>
                    <div class="actions">
                        <a href="{{ url_for('complete', task_id=task.id) }}" class="complete-btn">Complete</a>
                        <a href="{{ url_for('delete', task_id=task.id) }}" class="delete-btn">Delete</a>
                    </div>
                </li>
            {% endfor %}
        </ul>

        <h2>Completed</h2>
        <ul class="task-list">
            {% for task in tasks if task.done %}
                <li class="done">
                    <span>{{ task.title }}</span>
                    <div class="actions">
                         <a href="{{ url_for('complete', task_id=task.id) }}" class="uncomplete-btn">Uncomplete</a>
                         <a href="{{ url_for('edit', task_id=task.id) }}" class="edit-btn">Edit</a>
                        <a href="{{ url_for('delete', task_id=task.id) }}" class="delete-btn">Delete</a>
                    </div>
                </li>
            {% endfor %}
        </ul>
    </div>
</body>
</html>
```
