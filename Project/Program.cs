using Microsoft.EntityFrameworkCore;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// Подключаем строку подключения из переменной окружения или appsettings.json
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? Environment.GetEnvironmentVariable("DATABASE_URL");

var app = builder.Build();

app.MapGet("/", async () =>
{
    try
    {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        return Results.Ok("БД подключено");
    }
    catch (Exception ex)
    {
        return Results.Problem($"Ошибка подключения к БД: {ex.Message}");
    }
});

app.Run();
