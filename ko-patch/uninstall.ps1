# PdfCraft 한글판 제거
$dst = Join-Path $env:LOCALAPPDATA 'Programs\PdfCraft'
Get-Process pdfcraft -ErrorAction SilentlyContinue | Stop-Process -Force
foreach ($k in 'HKCU:\Software\Classes\SystemFileAssociations\.pdf\shell\PdfCraft.Edit',
               'HKCU:\Software\Classes\SystemFileAssociations\.pdf\shell\PdfCraft.Combine',
               'HKCU:\Software\Classes\Applications\pdfcraft.exe',
               'HKCU:\Software\Classes\.pdf\OpenWithList\pdfcraft.exe') {
    Remove-Item $k -Recurse -Force -ErrorAction SilentlyContinue
}
foreach ($dir in [Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop')) {
    Remove-Item (Join-Path $dir 'PdfCraft.lnk') -Force -ErrorAction SilentlyContinue
}
# 이 스크립트가 설치 폴더 안에서 실행 중일 수 있으므로 잠시 후 폴더를 지운다.
Start-Process cmd.exe -ArgumentList '/c', "timeout /t 2 >nul & rmdir /s /q `"$dst`"" -WindowStyle Hidden
Write-Host "제거 완료. (사용자 설정은 남겨 둡니다)"
