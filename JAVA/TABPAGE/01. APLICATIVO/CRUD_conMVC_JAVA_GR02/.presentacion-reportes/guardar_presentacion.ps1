$ErrorActionPreference = 'Stop'
$archivoFuente = Join-Path $PSScriptRoot 'salida/REPORTES_JAVA_MYSQL_GR02.pptx'
$archivoDestino = 'C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\JAVA\REPORTES\02. DOCUMENTACION\REPORTES_JAVA_MYSQL_GR02.pptx'
$plantillaOriginal = 'C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\JAVA\REPORTES\02. DOCUMENTACION\LOGIN_CRUD_JAVA_MYSQL_GR02_FINAL.pptx'
$informe = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'build/validacion.json') -Raw | ConvertFrom-Json
$hashFuente = (Get-FileHash -LiteralPath $archivoFuente -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hashFuente -ne $informe.finalSha256) { throw 'La presentación no coincide con la versión validada.' }
$hashPlantilla = (Get-FileHash -LiteralPath $plantillaOriginal -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hashPlantilla -ne $informe.fontSelection.referenceSha256) { throw 'La plantilla original cambió durante la elaboración.' }
if (Test-Path -LiteralPath $archivoDestino) { throw 'Ya existe una presentación con este nombre. No se sobrescribirá.' }
Copy-Item -LiteralPath $archivoFuente -Destination $archivoDestino
$hashDestino = (Get-FileHash -LiteralPath $archivoDestino -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hashDestino -ne $hashFuente) { throw 'No se pudo verificar el archivo guardado.' }
Write-Output "Presentación guardada y verificada: $archivoDestino"
Write-Output '16 diapositivas. Plantilla original conservada.'
