# =============================================================================
#  reparar-entorno.ps1 - Deja el replica set del curso listo para el dia 3/4
#
#  Uso:  powershell -ExecutionPolicy Bypass -File .\reparar-entorno.ps1
#  - Recrea los contenedores (los datos de los volumenes se conservan)
#  - Ejecuta scripts/reparar.sh dentro de mongo1: inicia el replica set y el
#    usuario admin si no existen, carga los datos si faltan, aplica los tags
#    del laboratorio 06 y crea los usuarios de PBM y PMM
#  Log: reparar-entorno.log
# =============================================================================
$ErrorActionPreference = "Continue"
$Raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
Start-Transcript -Path (Join-Path $Raiz "reparar-entorno.log") -Force | Out-Null
function Paso($t) { Write-Host ""; Write-Host "==== $t ====" -ForegroundColor Green }

Set-Location (Join-Path $Raiz "entorno")

Paso "Recreando contenedores del replica set"
docker compose up -d --force-recreate
Start-Sleep 15
docker compose ps

Paso "Replica set, admin, datos, tags y usuarios"
docker compose exec -T mongo1 bash /scripts/reparar.sh

Write-Host ""
Write-Host "Listo. Para trabajar: docker compose exec toolbox bash   y luego   mongosh `"`$RS`"" -ForegroundColor Yellow
Stop-Transcript | Out-Null
