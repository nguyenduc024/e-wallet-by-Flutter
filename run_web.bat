@echo off
cd /d "%~dp0"

echo.
echo  eWallet Demo - Web
echo  ==================
echo  URL app: http://localhost:5555
echo  (Cac port 5xxxx khac trong terminal la DEBUG, bo qua)
echo  Giu cua so nay mo khi dung app.
echo.

start "" cmd /c "ping -n 25 127.0.0.1 >nul && start http://localhost:5555"

flutter run -d web-server --web-hostname localhost --web-port 5555
