package ec.edu.chango.util;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import javax.imageio.ImageIO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import static org.junit.jupiter.api.Assertions.*;

class ImagenPerfilTest {
    @ParameterizedTest
    @CsvSource({"jpg,.jpg", "png,.png"})
    void conservaElArchivoCompletoSinNecesitarUnStreamAbierto(String formato, String extension) throws Exception {
        ByteArrayOutputStream salida = new ByteArrayOutputStream();
        BufferedImage imagen = new BufferedImage(3, 4, BufferedImage.TYPE_INT_RGB);
        assertTrue(ImageIO.write(imagen, formato, salida));
        byte[] original = salida.toByteArray();
        ImagenPerfil foto;
        try (ByteArrayInputStream entrada = new ByteArrayInputStream(original)) {
            foto = ImagenPerfil.leer(entrada);
        }
        assertEquals(extension, foto.getExtension());
        assertArrayEquals(original, foto.getContenido());
        assertNotNull(ImageIO.read(new ByteArrayInputStream(foto.getContenido())));
    }

    @ParameterizedTest
    @CsvSource({"RIFF1234WEBPVP8,WebP", "GIF89a123456,GIF", "BM1234567890,BMP",
        "0000ftypheic0000,HEIC/AVIF", "0000ftypavif0000,HEIC/AVIF", "texto cualquiera,formato desconocido"})
    void rechazaFormatosRenombradosEInformaComoConvertirlos(String contenido, String esperado) {
        IOException error = assertThrows(IOException.class, () -> ImagenPerfil.leer(
                new ByteArrayInputStream(contenido.getBytes(StandardCharsets.US_ASCII))));
        assertTrue(error.getMessage().contains(esperado));
        assertTrue(error.getMessage().contains("Paint"));
    }

    @Test void detectaUnArchivoVacio() {
        IOException error = assertThrows(IOException.class, () -> ImagenPerfil.leer(new ByteArrayInputStream(new byte[0])));
        assertTrue(error.getMessage().contains("archivo vacío"));
    }

    @Test void unaCabeceraJpegNoBastaSiElRestoDelArchivoEstaDanado() {
        byte[] falso = {(byte) 255, (byte) 216, (byte) 255, 0, 0};
        IOException error = assertThrows(IOException.class, () -> ImagenPerfil.leer(new ByteArrayInputStream(falso)));
        assertTrue(error.getMessage().contains("JPEG"));
        assertTrue(error.getMessage().contains("dañada o incompleta"));
    }

    @Test void rechazaMasDeCincoMegasAunqueElTamanoDeclaradoNoSeaCorrecto() {
        IOException error = assertThrows(IOException.class, () -> ImagenPerfil.leer(
                new ByteArrayInputStream(new byte[ImagenPerfil.MAXIMO_BYTES + 1])));
        assertEquals("La foto no puede superar 5 MB.", error.getMessage());
    }
}
