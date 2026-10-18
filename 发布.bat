@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion
title 彭老师专栏 · 一键发布到 GitHub

set "GP=C:\Users\Administrator\.workbuddy\binaries\PortableGit\versions\1.3.0"
set "REPO=H:\写作计划\github\public-site"
set "REMOTE=https://github.com/phxjchina/baibashi-jishu.git"

echo ============================================
echo    彭老师专栏 - 一键发布
echo ============================================
echo.

if not exist "%REPO%" (
  echo [!] 找不到目录: %REPO%
  pause
  exit /b 1
)

cd /d "%REPO%"

"%GP%\cmd\git.exe" --version >nul 2>&1
if errorlevel 1 (
  echo [!] Git 不可用，请检查 PortableGit 路径
  pause
  exit /b 1
)

"%GP%\cmd\git.exe" remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo [设置] 首次运行，正在添加远程仓库地址...
  "%GP%\cmd\git.exe" remote add origin %REMOTE%
  echo        已添加: %REMOTE%
  echo.
)

echo [1/4] 暂存本次改动...
"%GP%\cmd\git.exe" add -A
echo.

set /p MSG="[2/4] 提交说明 (直接回车用默认 'docs: 更新专栏内容'): "
if "!MSG!"=="" set "MSG=docs: 更新专栏内容"

"%GP%\cmd\git.exe" commit -m "!MSG!"
if errorlevel 1 (
  echo.
  echo [!] 没有需要提交的内容，或提交被取消
  pause
  exit /b 0
)
echo.

echo [3/4] 推送到 GitHub...
echo      提示: Username 填 phxjchina
echo            Password 粘贴你的 Personal Access Token
echo.
"%GP%\cmd\git.exe" push
if errorlevel 1 (
  echo.
  echo ============================================
  echo [!] 推送失败
  echo ============================================
  echo 常见原因:
  echo   1. GitHub 上还没有这个仓库
  echo      ^- 打开 https://github.com/new
  echo      ^- Repository name 填 baibashi-jishu
  echo      ^- 选 Public
  echo      ^- 不要勾 Add a README
  echo
  echo   2. Token 粘贴错误或已过期
  echo      ^- 重新到 https://github.com/settings/tokens/new 生成
  echo      ^- 勾选 repo 和 workflow 权限
  echo      ^- 粘贴时注意不要带空格和换行
  echo
  echo   3. 网络问题
  echo      ^- 检查是否能正常访问 github.com
  echo.
  echo 详细排查见: 发布手册.md
  pause
  exit /b 1
)
echo.

echo ============================================
echo    发布成功
echo ============================================
echo.
echo 站点地址 ^(Pages 生效约需 2 分钟^):
echo   https://phxjchina.github.io/baibashi-jishu/
echo.
echo 建议下一步:
echo   1. 打开仓库首页确认新文章已出现
echo   2. 到 Discussions 开一个对应话题
echo.
pause
