param([Parameter(Mandatory=$true)][string]$Entrada,[Parameter(Mandatory=$true)][string]$Salida)
$ErrorActionPreference = 'Stop'
$rutaEntrada = (Resolve-Path -LiteralPath $Entrada).Path
$rutaSalida = [System.IO.Path]::GetFullPath($Salida)
$word = $null
$doc = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $doc = $word.Documents.Open($rutaEntrada, $false, $true, $false)
    $doc.Repaginate()
    $paginas = $doc.ComputeStatistics(2)
    $doc.ExportAsFixedFormat($rutaSalida,17)
    Write-Output "PDF generado con Microsoft Word: $paginas páginas."
} finally {
    if ($doc) { $doc.Close(0); [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($doc) }
    if ($word) { $word.Quit(0); [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($word) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
