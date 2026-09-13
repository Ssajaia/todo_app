// Simple vanilla JS Todo app. Talks to the ASP.NET Core REST API at /api/todos.

const API_BASE = "/api/todos";

const listEl = document.getElementById("todo-list");
const formEl = document.getElementById("todo-form");
const inputEl = document.getElementById("todo-input");
const emptyStateEl = document.getElementById("empty-state");
const errorBannerEl = document.getElementById("error-banner");

function showError(message) {
  errorBannerEl.textContent = message;
  errorBannerEl.hidden = false;
}

function clearError() {
  errorBannerEl.hidden = true;
  errorBannerEl.textContent = "";
}

async function fetchTodos() {
  const res = await fetch(API_BASE);
  if (!res.ok) {
    throw new Error("Failed to load todos");
  }
  return res.json();
}

async function createTodo(title) {
  const res = await fetch(API_BASE, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title }),
  });
  if (!res.ok) {
    throw new Error("Failed to create todo");
  }
  return res.json();
}

async function updateTodo(id, changes) {
  const res = await fetch(`${API_BASE}/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(changes),
  });
  if (!res.ok) {
    throw new Error("Failed to update todo");
  }
  return res.json();
}

async function deleteTodo(id) {
  const res = await fetch(`${API_BASE}/${id}`, { method: "DELETE" });
  if (!res.ok) {
    throw new Error("Failed to delete todo");
  }
}

function renderTodos(todos) {
  listEl.innerHTML = "";

  if (todos.length === 0) {
    emptyStateEl.hidden = false;
    return;
  }
  emptyStateEl.hidden = true;

  for (const todo of todos) {
    const li = document.createElement("li");
    li.className = "todo-item" + (todo.completed ? " completed" : "");
    li.dataset.id = todo.id;

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = todo.completed;
    checkbox.addEventListener("change", () => onToggleCompleted(todo.id, checkbox.checked));

    const title = document.createElement("span");
    title.className = "todo-title";
    title.textContent = todo.title;

    const deleteBtn = document.createElement("button");
    deleteBtn.className = "delete-btn";
    deleteBtn.textContent = "✕";
    deleteBtn.setAttribute("aria-label", "Delete task");
    deleteBtn.addEventListener("click", () => onDelete(todo.id));

    li.appendChild(checkbox);
    li.appendChild(title);
    li.appendChild(deleteBtn);
    listEl.appendChild(li);
  }
}

async function loadTodos() {
  try {
    clearError();
    const todos = await fetchTodos();
    renderTodos(todos);
  } catch (err) {
    showError("Could not load tasks. Please try again.");
  }
}

async function onAddTodo(event) {
  event.preventDefault();
  const title = inputEl.value.trim();
  if (!title) {
    return;
  }

  try {
    clearError();
    await createTodo(title);
    inputEl.value = "";
    await loadTodos();
  } catch (err) {
    showError("Could not add task. Please try again.");
  }
}

async function onToggleCompleted(id, completed) {
  try {
    clearError();
    await updateTodo(id, { completed });
    await loadTodos();
  } catch (err) {
    showError("Could not update task. Please try again.");
  }
}

async function onDelete(id) {
  try {
    clearError();
    await deleteTodo(id);
    await loadTodos();
  } catch (err) {
    showError("Could not delete task. Please try again.");
  }
}

formEl.addEventListener("submit", onAddTodo);
loadTodos();
