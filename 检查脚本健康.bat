@echo off
chcp 65001 > nul 2>&1
setlocal enabledelayedexpansion
title BAT Script Health Check

set "PY=C:\Users\Administrator\.workbuddy\binaries\python\versions\3.13.12\python.exe"

rem locate publish script by wildcard, no Chinese literals
set "BAT="
for %%f in ("%~dp0*.bat") do (
  set "NAME=%%~nxf"
  if /i not "!NAME!"=="%~n0" if /i not "!NAME!"=="%~n0.lnk" set "BAT=%%f"
)

echo ============================================
echo    BAT Script Health Check
echo ============================================
echo.

if not exist "%PY%" (
  echo [ERROR] Python not found. Tell your assistant.
  pause
  exit /b 1
)

if not defined BAT (
  echo [ERROR] No publish script found in this folder.
  pause
  exit /b 1
)

echo   Checking: %%~nxBAT
echo.

"%PY%" -c "import sys;p=sys.argv[1];raw=open(p,'rb').read();d=raw.replace(b'\r\n',b'\n').decode('ascii');NL=chr(10);L=d.split(NL);B=chr(40);C=chr(41);K=chr(94);print('  1 pure LF leftovers :',raw.count(b'\n')-raw.count(b'\r\n'),'  want 0');print('  2 non ASCII bytes   :',sum(1 for b in raw if b>127),'  want 0');print('  3 hardcoded paths   :',len([l for l in L if 'H:' in l]),'  want 0');dep=0
for l in L: dep+=l.count(B)-l.count(K+B)-l.count(C)+l.count(K+C)
print('  4 bracket depth     :',dep,'  want 0');bad=0
for l in L:
    s=l.strip()
    if s.lower().startswith('echo'):
        b=s[5:] if len(s)>5 else ''
        if any(c in b for c in chr(62)+chr(60)+chr(38)+chr(124)+K+B+C): bad+=1
print('  5 echo bad chars    :',bad,'  want 0')" "%BAT%"

echo.
echo   All five should be 0.
echo   If any is not 0, tell your assistant.
echo.
pause
