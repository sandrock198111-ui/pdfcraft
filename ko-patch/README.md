# PdfCraft 한글 패치

[storytold/pdfcraft](https://github.com/storytold/pdfcraft) 위에 얹는 개인용 패치입니다. 브랜치: `ko/korean-patch`

## 들어 있는 것
- **한국어 UI**: `crates/ui-egui/src/i18n/ko.tsv` (2,674개 문구, AI 번역·원어민 검수 전), 언어 목록·날짜 언어에 `ko` 등록
- **한글 표시 (□□□ 문제)**: 설치된 한글 글꼴(맑은 고딕 / Apple SD Gothic Neo / 나눔고딕)을 UI 대체 글꼴로 사용 (`system_fonts::hangul_fallback`)
- **탐색기 우클릭 "PdfCraft에서 파일 결합"**: `pdfcraft --combine 파일…` 옵션, 여러 번 실행돼도 한 결합 목록으로 모임 (단일 인스턴스 넘기기), MSI 정의에도 메뉴 추가
- **배포 스크립트**: 이 폴더

## 최신 원본으로 업데이트
```powershell
powershell -ExecutionPolicy Bypass -File ko-patch\update.ps1
```
원본 최신 받기 → 패치 다시 얹기(rebase) → 빌드 → 테스트 → zip 패키지 → 내 GitHub에 올리기.
충돌이 나면 멈추고 안내를 보여줍니다.

번역 안 된 새 문구는 앱에서 영어로 보입니다. 목록 보기: `python ko-patch\missing-ko.py --tsv`

## 패키지만 다시 만들기
```powershell
powershell -ExecutionPolicy Bypass -File ko-patch\package.ps1
```
결과 zip 안의 `install.cmd`로 다른 PC에 설치합니다 (현재 사용자, 관리자 권한 불필요).

## 빌드에 필요한 것
Rust (rustup), Visual Studio 2022 Build Tools (C++), Python 3

## 정식 설치 파일(MSI) 만들기
추가로 필요: .NET SDK 8, `dotnet tool install --global wix --version 5.0.2`
```powershell
powershell -ExecutionPolicy Bypass -File packaging\windows\package.ps1 -Arch x64
```
결과: `dist\release\pdfcraft-<버전>-windows-x64.msi` (관리자 권한으로 설치, "설치된 앱"에서 제거).
VC++ 런타임이 필요 없게 정적 링크로 빌드합니다 (전체 빌드 약 15분).
