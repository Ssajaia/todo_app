using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoApp.Data;
using TodoApp.Models;

namespace TodoApp.Controllers;

[ApiController]
[Route("api/todos")]
public class TodosController : ControllerBase
{
    private readonly TodoDbContext _db;

    public TodosController(TodoDbContext db)
    {
        _db = db;
    }

    // GET /api/todos
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Todo>>> GetAll()
    {
        var todos = await _db.Todos
            .OrderBy(t => t.CreatedAt)
            .ToListAsync();
        return Ok(todos);
    }

    // GET /api/todos/{id}
    [HttpGet("{id:int}")]
    public async Task<ActionResult<Todo>> GetById(int id)
    {
        var todo = await _db.Todos.FindAsync(id);
        if (todo == null)
        {
            return NotFound();
        }
        return Ok(todo);
    }

    // POST /api/todos
    [HttpPost]
    public async Task<ActionResult<Todo>> Create([FromBody] CreateTodoDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Title))
        {
            return BadRequest(new { message = "Title is required." });
        }

        var todo = new Todo
        {
            Title = dto.Title.Trim(),
            Completed = false,
            CreatedAt = DateTime.UtcNow
        };

        _db.Todos.Add(todo);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = todo.Id }, todo);
    }

    // PUT /api/todos/{id}
    [HttpPut("{id:int}")]
    public async Task<ActionResult<Todo>> Update(int id, [FromBody] UpdateTodoDto dto)
    {
        var todo = await _db.Todos.FindAsync(id);
        if (todo == null)
        {
            return NotFound();
        }

        if (dto.Title != null)
        {
            if (string.IsNullOrWhiteSpace(dto.Title))
            {
                return BadRequest(new { message = "Title cannot be empty." });
            }
            todo.Title = dto.Title.Trim();
        }

        if (dto.Completed.HasValue)
        {
            todo.Completed = dto.Completed.Value;
        }

        await _db.SaveChangesAsync();
        return Ok(todo);
    }

    // DELETE /api/todos/{id}
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var todo = await _db.Todos.FindAsync(id);
        if (todo == null)
        {
            return NotFound();
        }

        _db.Todos.Remove(todo);
        await _db.SaveChangesAsync();

        return NoContent();
    }
}
