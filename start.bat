@echo off
chcp 65001 >nul
echo ========================================
echo   保利管道库存管理系统 - 启动脚本
echo ========================================
echo.

echo 正在启动服务...
echo.

java -jar -Xms256m -Xmx512m target\polyin-inventory.jar

pause
