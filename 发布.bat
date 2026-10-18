@echo off
chcp 65001 > nul
setlocal

echo ============================================
echo   彭老师专栏 - 一键发布到 GitHub
echo ============================================
echo.

cd /d "H:\写作计划\github\public-site"

if not exist .git (
  echo [!] 这还不是 git 仓库，请先看 发布手册.md 第 4 节完成初始化
  pause
  exit /b 1
)

echo [1/4] 检查待提交的文件...
git add .
echo.

echo [2/4] 准备提交...
git status --short
echo.

set /p MSG="请输入本次提交说明（例如 feat(S3): 新增《变量与内存》）: "
if "%MSG%"=="" set MSG="docs: 更新专栏内容"

git commit -m "%MSG%"
if errorlevel 1 (
  echo.
  echo [!] 没有需要提交的内容，或提交被取消
  pause
  exit /b 0
)
echo.

echo [3/4] 推送到 GitHub...
echo     提示: 用户名填 GitHub 用户名
echo     密码栏粘贴 Personal Access Token ^(不是账号密码^)
echo.
git push
if errorlevel 1 (
  echo.
  echo [!] 推送失败，请检查：
  echo     1. Token 是否过期或权限不足 ^(需要 repo 权限^)
  echo     2. 网络是否正常
  echo     3. 远程仓库地址是否正确
  echo     详细排查见 发布手册.md
  pause
  exit /b 1
)
echo.

echo [4/4] 完成！
echo.
echo ============================================
echo   发布成功
echo ============================================
echo.
echo 下一步:
echo   1. 打开仓库首页，确认新文章已出现
echo   2. 在 Discussions 开一个对应话题，邀请读者点评
echo.
echo 站点地址 ^(Pages 生效后约需 2 分钟^):
echo   https://%USERNAME%.github.io/baibashi-jishu/
echo   (把%%USERNAME%% 换成你的 GitHub 用户名)
echo.
pause
