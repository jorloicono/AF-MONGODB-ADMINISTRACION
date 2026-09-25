@echo off
REM Doble clic para arrancar todo el entorno del curso (instructor)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0levantar-todo.ps1"
pause
