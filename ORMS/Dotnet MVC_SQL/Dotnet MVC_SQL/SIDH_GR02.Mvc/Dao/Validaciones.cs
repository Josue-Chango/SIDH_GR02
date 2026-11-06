namespace SIDH_GR02.Mvc.Dao;

/// <summary>Error de datos del usuario; el controlador responde 400.</summary>
public class ValidacionException(string mensaje) : Exception(mensaje);

/// <summary>El registro solicitado no existe; el controlador responde 404.</summary>
public class NoEncontradoException() : Exception("El registro ya no existe. Actualice el listado.");

public static class Validaciones
{
    private static readonly TimeZoneInfo Zona = TimeZoneInfo.FindSystemTimeZoneById("America/Guayaquil");

    public static DateTime Ahora() => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, Zona);
    public static DateOnly Hoy() => DateOnly.FromDateTime(Ahora());

    public static void Exigir(bool condicion, string mensaje)
    {
        if (!condicion) throw new ValidacionException(mensaje);
    }

    public static string Texto(string? valor, int maximo, string etiqueta)
    {
        Exigir(!string.IsNullOrWhiteSpace(valor) && valor.Length <= maximo, $"{etiqueta}: ingrese de 1 a {maximo} caracteres.");
        return valor!.Trim();
    }

    public static void Vigencia(DateOnly? desde, DateOnly? hasta) =>
        Exigir(desde == null || hasta == null || hasta >= desde, "La fecha final no puede preceder a la inicial.");
}
