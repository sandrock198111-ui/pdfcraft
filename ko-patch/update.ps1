# 원본(storytold/pdfcraft) 최신 코드 위에 한글 패치를 다시 얹고, 빌드하고, 패키지를 만든다.
#   powershell -ExecutionPolicy Bypass -File ko-patch\update.ps1
#   -NoPackage : 빌드까지만   -NoPush : 내 GitHub에 올리지 않음
param([switch] $NoPackage, [switch] $NoPush)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"
Set-Location $repo

function Git { git @args; if ($LASTEXITCODE) { throw "git $args 실패" } }

if (git status --porcelain) { throw '커밋하지 않은 변경이 있습니다. 먼저 커밋하거나 정리하세요.' }
if (-not (git remote | Select-String -SimpleMatch 'upstream')) {
    Git remote add upstream https://github.com/storytold/pdfcraft
}

Write-Host '== 원본 최신 코드 받기'
Git fetch upstream main
$before = git rev-parse HEAD
git rebase upstream/main
if ($LASTEXITCODE) {
    Write-Host ''
    Write-Host '충돌이 났습니다. 충돌 파일을 고친 뒤 git add <파일>; git rebase --continue 로 이어가세요.'
    Write-Host '(포기하려면 git rebase --abort)'
    git status --short
    exit 1
}

Write-Host '== 새로 생긴 번역 대상 문구'
python ko-patch\missing-ko.py | Select-Object -Last 30

Write-Host '== 빌드 (처음이 아니면 보통 3~5분)'
cargo build --release -p pdfcraft -p pdfcraft-cli -j 4
if ($LASTEXITCODE) { throw '빌드 실패' }

Write-Host '== 한국어 카탈로그 테스트'
cargo test --release -p pdfcraft-ui-egui -j 4 --lib -- i18n
if ($LASTEXITCODE) { throw '테스트 실패: 위 메시지를 보고 ko.tsv를 고치세요.' }

if (-not $NoPackage) {
    & "$PSScriptRoot\package.ps1"
}
if (-not $NoPush -and (git rev-parse HEAD) -ne $before) {
    Write-Host '== 내 GitHub에 올리기'
    Git push --force-with-lease origin HEAD
}
Write-Host '완료'
