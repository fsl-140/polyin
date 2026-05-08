@echo off
chcp 65001 >nul
echo ========================================
echo   保利管道库存管理系统 - 服务管理
echo ========================================
echo.

echo 请选择操作：
echo   1. 安装服务
echo   2. 启动服务
echo   3. 停止服务
echo   4. 卸载服务
echo   5. 查看服务状态
echo   0. 退出
echo.

set /p choice=请输入选项 (0-5): 

if "%choice%"=="1" goto install
if "%choice%"=="2" goto start
if "%choice%"=="3" goto stop
if "%choice%"=="4" goto uninstall
if "%choice%"=="5" goto status
if "%choice%"=="0" goto end
goto end

:install
echo.
echo 正在安装 Windows 服务...
winsw.exe install
if %errorlevel% equ 0 (
    echo [成功] 服务安装完成
    echo 服务名称: 保利管道库存管理系统
    echo 启动类型: 自动启动
) else (
    echo [错误] 服务安装失败
    echo 请以管理员身份运行此脚本
)
pause
goto end

:start
echo.
echo 正在启动服务...
net start polyin-inventory
if %errorlevel% equ 0 (
    echo [成功] 服务已启动
    echo 访问地址: http://localhost:8082
) else (
    echo [错误] 服务启动失败
)
pause
goto end

:stop
echo.
echo 正在停止服务...
net stop polyin-inventory
if %errorlevel% equ 0 (
    echo [成功] 服务已停止
) else (
    echo [错误] 服务停止失败
)
pause
goto end

:uninstall
echo.
echo 正在卸载服务...
net stop polyin-inventory 2>nul
winsw.exe uninstall
if %errorlevel% equ 0 (
    echo [成功] 服务已卸载
) else (
    echo [错误] 服务卸载失败
)
pause
goto end

:status
echo.
echo 服务状态：
sc query polyin-inventory
echo.
echo 端口监听：
netstat -ano | findstr :8082
pause
goto end

:end
echo.
echo 操作完成
