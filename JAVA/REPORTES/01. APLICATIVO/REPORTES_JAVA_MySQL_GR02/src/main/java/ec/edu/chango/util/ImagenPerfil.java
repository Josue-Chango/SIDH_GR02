package ec.edu.chango.util;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import javax.imageio.ImageIO;

/** Valida la firma real y conserva los bytes de la foto sin volver a usar el stream del request. */
public final class ImagenPerfil {
    public static final int MAXIMO_BYTES = 5 * 1024 * 1024;
    private final byte[] contenido;
    private final String extension;

    private ImagenPerfil(byte[] contenido, String extension) {
        this.contenido = contenido;
        this.extension = extension;
    }

    public static ImagenPerfil leer(InputStream entrada) throws IOException {
        byte[] datos = entrada.readNBytes(MAXIMO_BYTES + 1);
        if (datos.length > MAXIMO_BYTES) throw new IOException("La foto no puede superar 5 MB.");
        String formato = describirFormato(datos);
        String extension = "JPEG".equals(formato) ? ".jpg" : "PNG".equals(formato) ? ".png" : null;
        if (extension == null) {
            throw new IOException("La imagen seleccionada no es un JPG o PNG válido: se detectó " + formato
                    + ". Si viene de un teléfono o de WhatsApp, ábrala en Paint y guárdela como JPEG o PNG.");
        }
        try (InputStream comprobacion = new ByteArrayInputStream(datos)) {
            if (ImageIO.read(comprobacion) == null) throw new IOException("Imagen no legible");
        } catch (IOException ex) {
            throw new IOException("Se detectó " + formato + ", pero la imagen está dañada o incompleta. "
                    + "Ábrala en Paint y guárdela de nuevo como JPEG o PNG.", ex);
        }
        return new ImagenPerfil(datos, extension);
    }

    public byte[] getContenido() { return contenido; }
    public String getExtension() { return extension; }

    public static String describirFormato(byte[] datos) {
        if (datos.length == 0) return "un archivo vacío";
        if (firma(datos, 0, 0xFF, 0xD8, 0xFF)) return "JPEG"; // También JFIF/JFXX.
        if (firma(datos, 0, 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)) return "PNG";
        if (texto(datos, 0, "GIF87a") || texto(datos, 0, "GIF89a")) return "GIF";
        if (texto(datos, 0, "BM")) return "BMP";
        if (texto(datos, 0, "RIFF") && texto(datos, 8, "WEBP")) return "WebP";
        if (texto(datos, 4, "ftyp")) {
            for (int i = 8; i + 4 <= Math.min(datos.length, 64); i += 4) {
                if (i == 12) continue; // Versión menor de la marca ISO BMFF.
                for (String marca : new String[]{"heic", "heix", "hevc", "hevx", "mif1", "msf1", "avif", "avis"}) {
                    if (texto(datos, i, marca)) return "HEIC/AVIF";
                }
            }
        }
        return "un formato desconocido";
    }

    private static boolean firma(byte[] datos, int inicio, int... firma) {
        if (datos.length < inicio + firma.length) return false;
        for (int i = 0; i < firma.length; i++) if ((datos[inicio + i] & 0xFF) != firma[i]) return false;
        return true;
    }

    private static boolean texto(byte[] datos, int inicio, String texto) {
        byte[] esperado = texto.getBytes(StandardCharsets.US_ASCII);
        if (datos.length < inicio + esperado.length) return false;
        for (int i = 0; i < esperado.length; i++) if (datos[inicio + i] != esperado[i]) return false;
        return true;
    }
}
