@echo off
chcp 65001 >nul
title Zhituo Server
echo ============================================
echo   智拓 · 服务启动器
echo ============================================
echo.

cd /d D:\WorkBuddy\运营\social-growth-agent

REM 优先使用 WorkBuddy 内置 Node/npm，避免系统 PATH 未配置时双击脚本失败
set "NODE_DIR=C:\Users\Administrator\.workbuddy\binaries\node\versions\22.22.2"
if exist "%NODE_DIR%\node.exe" (
    set "PATH=%NODE_DIR%;%PATH%"
) else (
    where node >nul 2>nul
    if errorlevel 1 (
        echo [错误] 未找到 Node.js，请先安装 Node.js 或更新启动脚本中的 NODE_DIR。
        pause
        exit /b 1
    )
)

REM 前端产物不存在时自动构建
if not exist "dist\index.html" (
    echo [提示] 未找到前端产物，正在构建（约1分钟）...
    call npm run build
    if errorlevel 1 (
        echo [错误] 构建失败，请检查代码。
        pause
        exit /b 1
    )
)

REM 端口 3000 已被占用时，不重复拉起服务
set "PORT_PID="
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r /c:":3000 .*LISTENING"') do set "PORT_PID=%%p"
if defined PORT_PID (
    echo [提示] 检测到端口 3000 已被进程 PID %PORT_PID% 占用。
    echo 如果 http://localhost:3000 可以打开，说明智拓已经在运行；正在打开浏览器...
    start "" "http://localhost:3000"
    pause
    exit /b 0
)

echo [提示] 浏览器访问: http://localhost:3000
echo [提示] 关闭本窗口即停止服务。
echo.
node node_modules\tsx\dist\cli.mjs server\index.ts

pause
