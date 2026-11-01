var builder = WebApplication.CreateBuilder(args);

builder.WebHost.ConfigureKestrel(options => options.AddServerHeader = false);
builder.Services.AddRazorPages();

var app = builder.Build();

app.MapGet("/healthz", () => Results.Text("Healthy", "text/plain"));
app.MapRazorPages();

app.Run();
