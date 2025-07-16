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
