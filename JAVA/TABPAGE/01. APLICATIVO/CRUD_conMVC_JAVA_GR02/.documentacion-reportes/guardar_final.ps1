$ErrorActionPreference = 'Stop'
$carpetaTrabajo = $PSScriptRoot
$destinoDocumento = 'C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\JAVA\REPORTES\02. DOCUMENTACION\CRUD_CONMVC_JAVA_GR02.docx'
$origenDocumento = Join-Path $carpetaTrabajo 'actualizado.docx'
$informe = Get-Content -LiteralPath (Join-Path $carpetaTrabajo 'verificacion.json') -Raw | ConvertFrom-Json
$hashActual = (Get-FileHash -LiteralPath $destinoDocumento -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hashActual -ne $informe.sha256_original) { throw 'El documento original cambió durante la edición. Se detiene el guardado para conservar esos cambios.' }
$hashCopia = (Get-FileHash -LiteralPath $origenDocumento -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hashCopia -ne $informe.sha256_actualizado) { throw 'La copia no coincide con la versión verificada.' }
Copy-Item -LiteralPath $origenDocumento -Destination $destinoDocumento -Force
$hashFinal = (Get-FileHash -LiteralPath $destinoDocumento -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hashFinal -ne $hashCopia) { throw 'No se pudo verificar el archivo guardado.' }
Get-Item -LiteralPath $destinoDocumento | Select-Object FullName,Length,LastWriteTime
Write-Output 'Documentación guardada y verificada: 20 pasos, 20 capturas, figuras 67 a 86.'
