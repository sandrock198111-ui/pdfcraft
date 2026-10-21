# 빌드 결과로 배포용 패키지(zip)를 만든다.
#   powershell -ExecutionPolicy Bypass -File ko-patch\package.ps1
# 결과: <저장소 상위 폴더>\PdfCraft-<버전>-ko-win64.zip
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$version = (Select-String -Path "$repo\Cargo.toml" -Pattern '^version\s*=\s*"([^"]+)"' | Select-Object -First 1).Matches[0].Groups[1].Value
$name = "PdfCraft-$version-ko-win64"
$out = Join-Path (Split-Path -Parent $repo) $name
$rel = "$repo\target\release"

foreach ($f in 'pdfcraft.exe', 'pdfcraft-cli.exe') {
    if (-not (Test-Path "$rel\$f")) { throw "$rel\$f 가 없습니다. 먼저 빌드하세요 (update.ps1)." }
}
if (-not (Test-Path "$repo\assets\models\text-recognition.rten")) {
    Push-Location $repo; try { cargo xtask models } finally { Pop-Location }
}

if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory $out | Out-Null
Copy-Item "$rel\pdfcraft.exe", "$rel\pdfcraft-cli.exe", "$repo\LICENSE-MIT", "$repo\LICENSE-APACHE", "$repo\NOTICE" $out
Copy-Item "$repo\assets\models" "$out\models" -Recurse

# VC++ 런타임: 없는 PC에서도 실행되도록 함께 넣는다.
$vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -property installationPath | Select-Object -First 1
$crt = Get-ChildItem "$vs\VC\Redist\MSVC\*\x64\Microsoft.VC14*.CRT" -Directory | Sort-Object FullName -Descending | Select-Object -First 1
Copy-Item "$($crt.FullName)\vcruntime140.dll", "$($crt.FullName)\vcruntime140_1.dll" $out

# PowerShell 5.1이 한글을 읽도록 UTF-8 BOM으로 쓴다.
$bom = New-Object System.Text.UTF8Encoding $true
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($f in 'install.ps1', 'uninstall.ps1') {
    [IO.File]::WriteAllText("$out\$f", [IO.File]::ReadAllText("$here\$f", [Text.Encoding]::UTF8), $bom)
}
$oem = [Text.Encoding]::GetEncoding(949)
foreach ($f in 'install', 'uninstall') {
    [IO.File]::WriteAllText("$out\$f.cmd", "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0$f.ps1`"`r`npause`r`n", $oem)
}
[IO.File]::WriteAllText("$out\읽어보세요.txt", [IO.File]::ReadAllText("$here\읽어보세요.txt", [Text.Encoding]::UTF8).Replace('{version}', $version), $bom)

Compress-Archive -Path "$out\*" -DestinationPath "$out.zip" -Force
Write-Host "패키지: $out.zip"
