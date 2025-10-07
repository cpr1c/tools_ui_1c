# пример многопоточного анализа для onescript
# каждый поток пишет результат работы плагинов в файлы report_<номер потока>.txt

# папка с выгрузкой конфигурации в файлы
$path = "C:\temp\SSL"

$files = Get-ChildItem -Path $path -File -Recurse -ErrorAction SilentlyContinue -Filter *.bsl | Select-Object -ExpandProperty FullName
$chunk_size = 100
$chunks = for($i = 0; $i -lt $files.length; $i += $chunk_size){, $files[$i..($i+$chunk_size-1)]}
$threads = 6

for ($i = 0; $i -lt $threads; $i++) {
    New-Item "report_$i.txt" -Force | Out-Null
}

$jobs = @($null) * $threads
$chunk_i = 0

while ($chunk_i -lt $chunks.Length) {

    for ($job_i = 0; $job_i -lt $threads; $job_i++) {
        $job = $jobs[$job_i]
        if ($null -eq $job -or $job.JobStateInfo.State -ne "Running") {
            if ($null -ne $job) {
                $result = Receive-Job -Job $job -AutoRemoveJob -Wait
                # Write-Host $job_i, $result
            }
            Write-Progress -Activity "Анализ в $threads потоков" -Status "Прогресс:" -PercentComplete ($chunk_i / $chunks.Length * 100)
            $job = Start-Job -ScriptBlock {
                Param([string]$workdir, [string]$script, [string]$file, [string]$report)
                Set-Location $workdir
                oscript.exe $script $file $report
            } -ArgumentList (Get-Location), ".\test4.os", ($chunks[$chunk_i++] -join ";"), "report_$job_i.txt"
            $jobs[$job_i] = $job
        }
    }

    Start-Sleep -Milliseconds 100

}