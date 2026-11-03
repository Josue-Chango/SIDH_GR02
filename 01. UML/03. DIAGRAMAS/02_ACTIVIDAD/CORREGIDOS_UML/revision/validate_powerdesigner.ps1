$ErrorActionPreference = 'Stop'
$reviewRoot = Split-Path -Parent $PSScriptRoot
$pdApp = New-Object -ComObject PowerDesigner.Application
$pdApp.InteractiveMode = 0
$nativeOutput = Join-Path $PSScriptRoot 'powerdesigner_png'
New-Item -ItemType Directory -Path $nativeOutput -Force | Out-Null
$results = @()
$graphDefinitions = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'diagramas_publicados.json') -Raw -Encoding utf8 | ConvertFrom-Json
function Get-ReviewPackages($package) {
    $package
    foreach ($child in $package.Packages) { Get-ReviewPackages $child }
}
foreach ($file in (Get-ChildItem -LiteralPath $reviewRoot -Filter 'DA_CU*.oom' | Sort-Object Name)) {
    $model = $null
    try {
        $model = $pdApp.OpenModel($file.FullName)
        if ($null -eq $model) { throw 'PowerDesigner no devolvió el modelo' }
        $cuNumber = [int]$file.BaseName.Substring(5,2)
        $questionNodes = @($graphDefinitions | Where-Object { $_.cu -eq $cuNumber } | ForEach-Object { $_.nodes } | Where-Object { $_.kind -eq 'decision' })
        foreach ($package in (Get-ReviewPackages $model)) {
            foreach ($decision in $package.Decisions) {
                $question = $questionNodes | Where-Object { $_.label -eq $decision.Name } | Select-Object -First 1
                if ($null -ne $question) {
                    $decision.Expression = $question.label
                    $decision.ExpressionAlias = ($question.lines -join "`r`n")
                }
            }
        }
        # Comprobar el archivo realmente persistido, después de su normalización nativa.
        $model.Save($file.FullName, $false, '')
        $model.Close($false)
        $model = $pdApp.OpenModel($file.FullName)
        $options = $model.GetPackageOptions()
        $controller = $options.GetCheckModelControler()
        foreach ($category in $controller.Categories) {
            foreach ($check in $category.Checks) {
                $check.Execution = 1
                $check.AutoCorrect = 0
            }
        }
        $errorCount = 0
        $warningCount = 0
        $controller.Execute([ref]$errorCount, [ref]$warningCount)
        $messages = @()
        foreach ($message in $controller.Messages) {
            $messages += [ordered]@{
                check = $message.CheckName
                object = $message.ObjectDescription
                severity = $message.Severity
                description = $message.ShortDescription
                details = $message.AdditionalMessages
            }
        }
        $exports = @()
        $diagramCount = 0
        $activityCount = 0
        $flowCount = 0
        foreach ($package in (Get-ReviewPackages $model)) {
            $activityCount += $package.Activities.Count
            $flowCount += $package.Flows.Count
            foreach ($diagram in $package.ActivityDiagrams) {
                $diagramCount++
                $png = Join-Path $nativeOutput ($file.BaseName + '_' + $diagram.Code + '.png')
                try { $diagram.ExportImage($png); $exports += $png }
                catch { $exports += ('ERROR: ' + $_.Exception.Message) }
            }
        }
        $row = [ordered]@{
            file = $file.Name
            errors = $errorCount
            warnings = $warningCount
            activities = $activityCount
            flows = $flowCount
            diagrams = $diagramCount
            messages = $messages
            exports = $exports
        }
        if ($errorCount -eq 0) { $model.Save($file.FullName, $false, '') }
        $results += $row
        Write-Output ($file.Name + ': ' + $messages.Count + ' hallazgos, ' + $diagramCount + ' diagramas')
    }
    catch {
        $results += [ordered]@{ file = $file.Name; failure = $_.Exception.Message }
        Write-Output ($file.Name + ': ERROR ' + $_.Exception.Message)
    }
    finally {
        if ($null -ne $model) { $model.Close($false) }
    }
    $results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'validacion_powerdesigner.json') -Encoding utf8
}
