@echo off
REM Doble clic: repara el replica set del curso (no borra datos)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0reparar-entorno.ps1"
pause
