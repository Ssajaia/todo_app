namespace TodoApp.Models;

public class CreateTodoDto
{
    public string Title { get; set; } = string.Empty;
}

public class UpdateTodoDto
{
    public string? Title { get; set; }
    public bool? Completed { get; set; }
}
