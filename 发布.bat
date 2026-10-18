@echo off
chcp 65001 > nul 2>&1
setlocal enabledelayedexpansion
title Publish Column Articles to GitHub

set "GP=C:\Users\Administrator\.workbuddy\binaries\PortableGit\versions\1.3.0"
set "GIT=%GP%\cmd\git.exe"
set "REPO=%~dp0"
if "%REPO:~-1%"=="\" set "REPO=%REPO:~0,-1%"
set "REMOTE=https://github.com/phxjchina/baibashi-jishu.git"

echo ============================================
echo    Publish Articles to GitHub
echo ============================================
echo.

if not exist "%REPO%\.git" (
  echo [ERROR] Not a git repository: %REPO%
  pause
  exit /b 1
)

if not exist "%GIT%" (
  echo [ERROR] Git not found: %GIT%
  echo.
  echo Please tell your assistant. Do not try to fix it yourself.
  pause
  exit /b 1
)

cd /d "%REPO%"

"%GIT%" remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo [SETUP] Adding remote repository...
  "%GIT%" remote add origin %REMOTE%
  echo         Added: %REMOTE%
  echo.
)

echo [1/4] Staging changes...
"%GIT%" add -A
echo.

set "MSG="
set /p MSG="[2/4] Commit message (press Enter for default): "
if "!MSG!"=="" set "MSG=docs: update articles"

"%GIT%" commit -m "!MSG!"
if errorlevel 1 (
  echo.
  echo [SKIP] Nothing to commit, or commit cancelled.
  pause
  exit /b 0
)
echo.

echo [3/4] Pushing to GitHub...
echo.
echo   >>> Username:  phxjchina
echo   >>> Password: PASTE YOUR TOKEN HERE
echo       (screen shows nothing while pasting - this is normal)
echo.
"%GIT%" push -u origin main
if errorlevel 1 (
  echo.
  echo ============================================
  echo [FAILED] Push did not succeed
  echo ============================================
  echo.
  echo Most common causes:
  echo.
  echo   1. Token missing, wrong, or expired
  echo      Fix: open https://github.com/settings/tokens/new
  echo           Note    = writing-publish
  echo           Expires = 90 days
  echo           Check   = repo, workflow
  echo           Then generate and copy the ghp_ string.
  echo.
  echo   2. Token pasted with extra space or newline
  echo      Fix: copy it again, paste directly, do not retype.
  echo.
  echo   3. Network problem
  echo      Fix: check you can open github.com in your browser.
  echo.
  echo If you get stuck, screenshot the error and
  echo show it to your assistant.
  echo.
  pause
  exit /b 1
)
echo.

echo ============================================
echo    SUCCESS
echo ============================================
echo.
echo Site will be live in about 2 minutes:
echo   https://phxjchina.github.io/baibashi-jishu/
echo.
echo Next:
echo   1. Open the repo and confirm your article appears
echo   2. Start a discussion thread for reader feedback
echo.
pause
