# PdfCraft 한글판 설치 (현재 사용자용, 관리자 권한 불필요)
$ErrorActionPreference = 'Stop'
$src = Split-Path -Parent $MyInvocation.MyCommand.Path
$dst = Join-Path $env:LOCALAPPDATA 'Programs\PdfCraft'

Get-Process pdfcraft -ErrorAction SilentlyContinue | Stop-Process -Force
New-Item -ItemType Directory -Force $dst | Out-Null
foreach ($item in 'pdfcraft.exe', 'pdfcraft-cli.exe', 'vcruntime140.dll', 'vcruntime140_1.dll', 'models', 'LICENSE-MIT', 'LICENSE-APACHE', 'NOTICE', 'uninstall.ps1', 'uninstall.cmd') {
    $p = Join-Path $src $item
    if (Test-Path $p) { Copy-Item $p $dst -Recurse -Force }
}
$exe = Join-Path $dst 'pdfcraft.exe'

# 시작 메뉴 / 바탕화면 바로가기
$shell = New-Object -ComObject WScript.Shell
foreach ($dir in [Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop')) {
    $lnk = $shell.CreateShortcut((Join-Path $dir 'PdfCraft.lnk'))
    $lnk.TargetPath = $exe
    $lnk.WorkingDirectory = $dst
    $lnk.IconLocation = "$exe,0"
    $lnk.Save()
}

# PDF 우클릭 메뉴 (Windows 11: "추가 옵션 표시" 안)
$base = 'HKCU:\Software\Classes\SystemFileAssociations\.pdf\shell'
$menus = @(
    @{ Key = 'PdfCraft.Edit'; Label = 'PdfCraft로 열기'; Args = '"%1"' },
    @{ Key = 'PdfCraft.Combine'; Label = 'PdfCraft에서 파일 결합…'; Args = '--combine "%1"' }
)
foreach ($m in $menus) {
    $k = Join-Path $base $m.Key
    New-Item -Path "$k\command" -Force | Out-Null
    Set-ItemProperty -Path $k -Name '(default)' -Value $m.Label
    Set-ItemProperty -Path $k -Name 'Icon' -Value "`"$exe`",0"
    Set-ItemProperty -Path $k -Name 'MultiSelectModel' -Value 'Document'
    Set-ItemProperty -Path "$k\command" -Name '(default)' -Value "`"$exe`" $($m.Args)"
}

# "연결 프로그램" 목록에 표시 (기본 PDF 프로그램은 바꾸지 않음)
$app = 'HKCU:\Software\Classes\Applications\pdfcraft.exe'
New-Item -Path "$app\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path $app -Name 'FriendlyAppName' -Value 'PdfCraft'
Set-ItemProperty -Path "$app\shell\open\command" -Name '(default)' -Value "`"$exe`" `"%1`""
New-Item -Path "$app\SupportedTypes" -Force | Out-Null
Set-ItemProperty -Path "$app\SupportedTypes" -Name '.pdf' -Value ''
New-Item -Path 'HKCU:\Software\Classes\.pdf\OpenWithList\pdfcraft.exe' -Force | Out-Null

Write-Host "설치 완료: $dst"
Write-Host "PDF 우클릭 > (추가 옵션 표시) > 'PdfCraft에서 파일 결합…' 으로 여러 PDF를 결합할 수 있습니다."
