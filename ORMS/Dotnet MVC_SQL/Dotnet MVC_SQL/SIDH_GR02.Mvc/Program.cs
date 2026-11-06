using System.Text.Encodings.Web;
using System.Text.Unicode;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.WebEncoders;
using SIDH_GR02.Mvc.Controllers;
using SIDH_GR02.Mvc.Dao;
using SIDH_GR02.Mvc.Data;

var builder = WebApplication.CreateBuilder(args);

// Persistencia: EF Core + Pomelo sobre el MySQL local (cadena "Sidh" en appsettings.json).
var cadena = builder.Configuration.GetConnectionString("Sidh")
    ?? throw new InvalidOperationException("Configure ConnectionStrings:Sidh en appsettings.json.");
builder.Services.AddDbContextFactory<SidhDbContext>(o =>
    o.UseMySql(cadena, new MySqlServerVersion(new Version(8, 0, 44))));
builder.Services.AddSingleton<Transacciones>();

builder.Services.AddScoped<DepartamentoDao>();
builder.Services.AddScoped<EstadoDao>();
builder.Services.AddScoped<CargoDao>();
builder.Services.AddScoped<PacienteDao>();
builder.Services.AddScoped<ContactoPacienteDao>();
builder.Services.AddScoped<CatalogoDao>();
builder.Services.AddScoped<ValorCatalogoDao>();

// Razor emite tildes y eñes tal cual (sigue escapando <, >, &, comillas).
builder.Services.Configure<WebEncoderOptions>(o => o.TextEncoderSettings = new TextEncoderSettings(UnicodeRanges.All));
builder.Services.AddControllersWithViews(o =>
{
    o.Filters.Add<ManejoErroresFilter>();
    o.Filters.Add(new AutoValidateAntiforgeryTokenAttribute()); // equivale al token CSRF de ProteccionFilter
});

var app = builder.Build();

// Equivale a hbm2ddl.auto=validate: la aplicación no arranca si el esquema no coincide.
await ValidadorEsquema.ValidarAsync(app.Services);

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/error");
    app.UseHsts();
}

app.Use(async (contexto, siguiente) =>
{
    contexto.Response.Headers.XContentTypeOptions = "nosniff";
    contexto.Response.Headers.CacheControl = "no-store";
    await siguiente();
});

app.UseRouting();
app.MapStaticAssets();
app.MapControllers().WithStaticAssets();

app.Run();
