$ErrorActionPreference='Stop'
$reviewRoot=Split-Path -Parent $PSScriptRoot
$pd=New-Object -ComObject PowerDesigner.Application
$pd.InteractiveMode=0
$graphs=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'diagramas_publicados.json') -Raw -Encoding utf8 | ConvertFrom-Json
$model=$pd.OpenModel((Join-Path $reviewRoot 'DA_CU01_Iniciar_Sesion.oom'))
$diagram=$model.Packages.Item(1).ActivityDiagrams.Item(0)
$graph=$graphs | Where-Object {$_.cu -eq 1 -and $_.suffix -eq 'b'}
$flowSymbols=@($diagram.Symbols | Where-Object {$_.IsKindOf(-837026041)})
Write-Output ('Diagrama '+$diagram.Code+' / '+$flowSymbols.Count+' flujos')
foreach($mode in @(0,1,2)) {
    for($i=0;$i -lt $flowSymbols.Count;$i++) {
        $s=$flowSymbols[$i]
        $ps=$graph.edges[$i].points
        $str='('+ (($ps | ForEach-Object { '('+[math]::Round($_[0]*2540/30)+','+[math]::Round($_[1]*2540/30)+')' }) -join ',') + ')'
        $s.AutomaticRoutingState=$mode
        $s.ListOfPoints=$str
    }
    $diagram.ExportImage((Join-Path $PSScriptRoot ('probe_route_'+$mode+'.png')))
    Write-Output ('Exportado modo '+$mode)
}
$model.Close($false)
