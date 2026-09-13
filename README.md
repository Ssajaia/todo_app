# Todo App

A very simple Todo web application, intended as a lightweight workload for DevOps and deployment
experiments (Docker, CI/CD, Terraform, Azure, monitoring, etc.). The application itself is kept
intentionally minimal — no auth, no frameworks, no extra features.

## Technologies used

- **Frontend:** HTML, CSS, vanilla JavaScript (no frameworks)
- **Backend:** ASP.NET Core Web API (.NET 8)
- **Database:** SQLite (via EF Core)
- **Containerization:** Docker, Docker Compose

## Project structure

```text
todo-app/
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── app.js
│
├── backend/
│   ├── Controllers/
│   │   └── TodosController.cs
│   ├── Models/
│   │   ├── Todo.cs
│   │   └── TodoDtos.cs
│   ├── Data/
│   │   └── TodoDbContext.cs
│   ├── Program.cs
│   ├── appsettings.json
│   └── backend.csproj
│
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```

## Running locally (without Docker)

Requires the [.NET 8 SDK](https://dotnet.microsoft.com/download).

```bash
cd backend
dotnet restore
dotnet run
```

By default the API serves both the REST endpoints and the static frontend (from `wwwroot`, or
directly from `frontend/` if you copy it in). For local development you can also just open
`frontend/index.html` in a browser and point requests at the running API — but the simplest
option is to run it through Docker Compose (below), which serves everything from one origin.

The API will listen on the port configured by ASP.NET Core (see `Properties/launchSettings.json`
or the `ASPNETCORE_URLS` environment variable).

## Running with Docker

Requires Docker and Docker Compose.

```bash
docker compose up --build
```

Then open **http://localhost:8080** in your browser.

To stop:

```bash
docker compose down
```

To reset the data (removes the SQLite volume):

```bash
docker compose down -v
```

### Configuration

Configuration is provided via environment variables (see `.env.example`). Copy it to `.env` and
adjust as needed:

| Variable                 | Description                                  | Default                              |
|---------------------------|-----------------------------------------------|---------------------------------------|
| `APP_PORT`                | Host port the app is exposed on               | `8080`                                 |
| `ASPNETCORE_ENVIRONMENT`  | ASP.NET Core environment name                 | `Production`                           |
| `CONNECTION_STRING`       | SQLite connection string (path in container)  | `Data Source=/app/data/todos.db`      |

The SQLite database file is stored in a named Docker volume (`todo-data`) so data survives
container restarts.

## API endpoints

| Method | Endpoint             | Description                  |
|--------|-----------------------|-------------------------------|
| GET    | `/api/todos`          | List all todos                |
| GET    | `/api/todos/{id}`     | Get a single todo by id        |
| POST   | `/api/todos`          | Create a new todo              |
| PUT    | `/api/todos/{id}`     | Update a todo (title/completed) |
| DELETE | `/api/todos/{id}`     | Delete a todo                  |
| GET    | `/health`              | Health check                   |

### Todo shape

```json
{
  "id": 1,
  "title": "Learn Docker",
  "completed": false,
  "createdAt": "2026-09-12T10:00:00Z"
}
```

### Example requests

Create a todo:

```bash
curl -X POST http://localhost:8080/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Docker"}'
```

Mark a todo as completed:

```bash
curl -X PUT http://localhost:8080/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'
```

Delete a todo:

```bash
curl -X DELETE http://localhost:8080/api/todos/1
```
