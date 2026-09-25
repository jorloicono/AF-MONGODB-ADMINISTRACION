# 00 · Preparación del entorno

Esta guía se hace **antes del primer día**. Lleva unos 30-45 minutos, casi todo de descargas.

## Requisitos del equipo

| Recurso | Mínimo | Recomendado |
|---------|--------|-------------|
| RAM | 8 GB | 16 GB (el día 4 PMM Server consume 2-3 GB extra) |
| Disco libre | 10 GB | 20 GB |
| CPU | x86-64 con AVX, o Apple Silicon | 4 núcleos o más |
| Permisos | Administrador para instalar Docker | |

MongoDB 5.0 y posteriores exigen una CPU con instrucciones **AVX**. Cualquier equipo de los últimos diez años las tiene, pero algunas máquinas virtuales antiguas no las exponen.

## 1. Instalar Docker

En **Windows 10/11** instala [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) con el backend **WSL 2**. Necesitas tener la virtualización activada en la BIOS/UEFI y permisos de administrador. Tras instalarlo, reinicia el equipo y abre Docker Desktop una vez para que termine la configuración.

En **macOS** instala [Docker Desktop para Mac](https://docs.docker.com/desktop/setup/install/mac-install/) eligiendo la versión de tu procesador (Intel o Apple Silicon).

En **Linux** instala [Docker Engine](https://docs.docker.com/engine/install/) y el plugin `docker compose`. Añade tu usuario al grupo `docker` para no tener que usar `sudo`.

En Docker Desktop, entra en *Settings → Resources* y asigna **al menos 6 GB de memoria** al motor de Docker (en Windows con WSL 2 se controla desde el fichero `.wslconfig`).

## 2. Verificar la instalación

```bash
docker version
docker compose version
docker run --rm hello-world
```

Los tres comandos deben funcionar sin errores. `docker compose version` debe ser 2.20 o superior.

## 3. Descargar el repositorio

Con Git:

```bash
git clone <URL-DEL-REPOSITORIO> mongodb-administracion
cd mongodb-administracion
```

Si usas Windows y Git, comprueba que los scripts `.sh` conservan los finales de línea Unix. El fichero `.gitattributes` del repositorio ya lo fuerza, pero si descargas el ZIP y lo abres con un editor que convierte a CRLF, el laboratorio de TLS fallará.

## 4. Descargar las imágenes

Ejecuta esto desde la carpeta del repositorio. Son unos 5 GB en total:

```bash
docker pull mongodb/mongodb-community-server:8.0-ubi9
docker pull mongodb/mongodb-community-server:7.0-ubi9
docker pull mongo:8.0
docker pull alpine/openssl
docker pull percona/percona-server-mongodb:8.0
docker pull percona/percona-backup-mongodb:2.15.0
docker pull percona/pmm-server:3
docker pull percona/pmm-client:3
```

## 5. Prueba de humo

```bash
cd entorno
docker compose up -d
docker compose ps
```

Deben aparecer `mongo1`, `mongo2`, `mongo3` y `toolbox` en estado `running`, y `keygen` en estado `exited (0)`. Comprueba que las herramientas responden:

```bash
docker compose exec mongo1 mongosh --quiet --eval "db.version()"
docker compose exec toolbox mongodump --version
```

El primer comando debe devolver `8.0.x`. Si todo está bien, para el entorno **sin borrarlo**:

```bash
docker compose stop
```

## Problemas frecuentes

**"WSL 2 installation is incomplete" o Docker no arranca en Windows.** Ejecuta `wsl --update` en una consola de administrador y reinicia.

**"port is already allocated".** Solo el laboratorio de PMM publica un puerto en tu equipo (8443). Si está ocupado, cambia el puerto de la izquierda en `entorno/compose.pmm.yml`.

**Descargas bloqueadas por el proxy corporativo.** Configura el proxy en Docker Desktop (*Settings → Resources → Proxies*) o pide al equipo de sistemas acceso a `registry-1.docker.io`, `auth.docker.io` y `production.cloudflare.docker.com`.

**Límite de descargas de Docker Hub.** Los usuarios anónimos tienen un límite de descargas por IP. Si toda la clase sale por la misma IP, iniciad sesión con `docker login` (una cuenta gratuita basta) o descargad las imágenes el día anterior.

**Mac con Apple Silicon.** Todas las imágenes del curso publican variante ARM64, pero si alguna diera problemas, Docker Desktop puede ejecutar la variante x86 con emulación activando *Use Rosetta for x86/amd64 emulation*.
