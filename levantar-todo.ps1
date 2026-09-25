# =============================================================================
#  levantar-todo.ps1 - Arranca TODO el entorno del curso en Windows (instructor)
#
#  Uso (PowerShell, en la carpeta del repositorio):
#     powershell -ExecutionPolicy Bypass -File .\levantar-todo.ps1
#
#  Deja en marcha: replica set rs0 con datos, usuarios de PBM y PMM, agentes
#  PBM configurados, PMM Server + Client con los tres nodos registrados,
#  el entorno del dia 1 y el de Percona del laboratorio 10.
#  Log: levantar-todo.log
# =============================================================================
$ErrorActionPreference = "Continue"
$Raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
Start-Transcript -Path (Join-Path $Raiz "levantar-todo.log") -Force | Out-Null

function Paso($t) { Write-Host ""; Write-Host "==== $t ====" -ForegroundColor Green }

Paso "Comprobando Docker"
docker info *> $null
if ($LASTEXITCODE -ne 0) {
  $dd = "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
  if (Test-Path $dd) { Write-Host "Arrancando Docker Desktop..."; Start-Process $dd }
  for ($i = 0; $i -lt 60; $i++) { Start-Sleep 5; docker info *> $null; if ($LASTEXITCODE -eq 0) { break } }
}
docker info *> $null
if ($LASTEXITCODE -ne 0) { Write-Host "Docker no responde. Abre Docker Desktop y vuelve a ejecutar." -ForegroundColor Red; Stop-Transcript; exit 1 }
docker version --format "Docker {{.Server.Version}}"
docker compose version

Paso "Descargando imagenes"
$imagenes = @(
  "mongodb/mongodb-community-server:8.0-ubi9", "mongodb/mongodb-community-server:7.0-ubi9", "mongo:8.0",
  "alpine/openssl", "percona/percona-server-mongodb:8.0", "percona/percona-backup-mongodb:2.15.0",
  "percona/pmm-server:3", "percona/pmm-client:3")
foreach ($img in $imagenes) { Write-Host "-> $img"; docker pull -q $img }

Paso "Replica set rs0"
Set-Location (Join-Path $Raiz "entorno")
docker compose up -d
Start-Sleep 15
docker compose exec -T mongo1 mongosh --quiet /scripts/bootstrap-rs.js
Start-Sleep 5
docker compose exec -T toolbox bash /scripts/estado.sh

Paso "Datos del curso (tienda)"
docker compose exec -T toolbox bash /scripts/datos.sh

Paso "Usuarios de PBM y PMM"
docker compose exec -T toolbox bash /scripts/usuarios.sh

Paso "Percona Backup for MongoDB"
docker compose -f compose.yml -f compose.pbm.yml up -d
Start-Sleep 20
docker exec pbm1 pbm config --file /scripts/pbm-config.yaml
Start-Sleep 10
docker exec pbm1 pbm status

Paso "Profiler y PMM"
docker compose exec -T toolbox bash /scripts/profiler.sh
docker compose -f compose.yml -f compose.pmm.yml up -d
Write-Host "Esperando a que PMM Server y el cliente esten listos (hasta 6 min)..."
for ($i = 0; $i -lt 36; $i++) {
  Start-Sleep 10
  docker exec pmm-client pmm-admin status *> $null
  if ($LASTEXITCODE -eq 0) { break }
}
foreach ($n in @("mongo1", "mongo2", "mongo3")) {
  docker exec pmm-client pmm-admin add mongodb --username=pmm --password=PmmCurso2026 --host=$n --port=27017 --service-name=$n --cluster=rs0 --replication-set=rs0 --query-source=profiler --enable-all-collectors
}
docker exec pmm-client pmm-admin list

Paso "Entorno del dia 1"
Set-Location (Join-Path $Raiz "dia1")
docker compose up -d solo legacy toolbox

Paso "Entorno Percona (laboratorio 10)"
Set-Location (Join-Path $Raiz "dia3\lab10-auditoria-cifrado")
docker compose up -d

Paso "Resumen"
Set-Location $Raiz
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
Write-Host ""
Write-Host "PMM:  https://localhost:8443   (admin / CursoMongo2026)" -ForegroundColor Yellow
Write-Host "Replica set: cd entorno; docker compose exec toolbox bash; mongosh `"`$RS`"" -ForegroundColor Yellow
Stop-Transcript | Out-Null
