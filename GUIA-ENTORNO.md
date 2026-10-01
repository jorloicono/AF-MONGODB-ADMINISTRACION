# Guía de uso del entorno del curso (instructor)

Esta guía explica cómo arrancar, usar, reparar y apagar el entorno Docker del curso de Administración de MongoDB en un equipo Windows. Todos los comandos se escriben en **PowerShell**, situado en la carpeta del repositorio (`AF-MONGODB-ADMINISTRACION`) o en la subcarpeta que se indique.

## 1. Antes de empezar cada día

Abre **Docker Desktop** y espera a que abajo a la izquierda ponga *Engine running*. Sin eso, ningún comando `docker` funciona.

## 2. Primera puesta en marcha (una sola vez)

Haz doble clic en **`levantar-todo.bat`**. Descarga las imágenes, crea el replica set, carga los datos, configura PBM y PMM y arranca los entornos del día 1 y del laboratorio 10. La primera vez tarda entre 15 y 25 minutos. Todo lo que hace queda en `levantar-todo.log`.

Si solo quieres el replica set de los días 2 a 4, sin PBM ni PMM:

```powershell
cd entorno
docker compose up -d
docker compose exec mongo1 bash /scripts/reparar.sh
```

## 3. Trabajar con el replica set

Desde la carpeta `entorno`:

```powershell
docker compose ps                                   # ¿están los contenedores en marcha?
docker compose exec toolbox bash /scripts/estado.sh # PRIMARY, SECONDARY y lag
docker compose exec toolbox bash                    # entrar en el puesto de administración
```

Una vez dentro del toolbox (el prompt cambia a `root@toolbox:/scripts#`):

```bash
mongosh "$RS"            # conexión al replica set como admin
bash estado.sh           # los scripts se lanzan con "bash nombre.sh"
exit                     # volver a PowerShell
```

Los scripts de la carpeta `entorno/scripts` **no** se ejecutan escribiendo solo su nombre: hay que anteponer `bash` (dentro del toolbox) o usar `docker compose exec toolbox bash /scripts/<nombre>.sh` (desde PowerShell).

## 4. Si algo no funciona: reparar

Haz doble clic en **`reparar-entorno.bat`** (o ejecuta `docker compose exec mongo1 bash /scripts/reparar.sh` desde `entorno`). Es seguro lanzarlo siempre, porque no borra nada:

- Recrea los contenedores (los datos viven en volúmenes y se conservan).
- Si el replica set no existe, lo inicia con `mongo1` como primario y crea el usuario `admin` / `CursoMongo2026`.
- Si la colección `tienda.pedidos` está vacía, carga los datos del curso.
- Aplica los tags del laboratorio 06 y crea los usuarios de PBM y PMM.
- Termina mostrando el estado: debe haber un PRIMARY y dos SECONDARY con lag 0.

Para ver con detalle qué le pasa a cada nodo:

```powershell
docker compose exec toolbox bash /scripts/diagnostico.sh
docker compose logs --tail 30 mongo1
```

## 5. Problemas conocidos y su causa

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `cp: cannot create regular file '/tmp/keyfile': Permission denied` en bucle | Versión antigua de `compose.yml` y Docker reinició los contenedores | `git pull` y `docker compose up -d --force-recreate` |
| `MongoServerSelectionError: Server selection timed out` | No hay primario o el replica set no existe (volúmenes nuevos) | `reparar-entorno.bat` |
| `Authentication failed` con el usuario admin | El replica set es nuevo y el usuario aún no existe | `reparar-entorno.bat` |
| `bash: estado.sh: No such file or directory` dentro del toolbox | El toolbox se creó desde otra copia de la carpeta del repositorio que ya no existe | `docker compose up -d --force-recreate` desde la carpeta `entorno` actual |
| `bash: estado.sh: command not found` | Falta `bash` delante | `bash estado.sh` |
| Docker no responde | Docker Desktop cerrado o arrancando | Abrir Docker Desktop y esperar a *Engine running* |

Dos reglas para no perder el trabajo entre días:

- Para parar, usa **`docker compose stop`**. Nunca `docker compose down -v` ni borres los volúmenes desde Docker Desktop: el `-v` elimina los datos, los usuarios y la configuración del replica set.
- Si mueves la carpeta del repositorio a otro sitio, ejecuta después `docker compose up -d --force-recreate` desde la nueva ubicación, porque los contenedores recuerdan la ruta antigua.

## 6. PBM y PMM

```powershell
cd entorno
docker compose -f compose.yml -f compose.pbm.yml up -d     # agentes de backup
docker exec pbm1 pbm status
docker compose -f compose.yml -f compose.pmm.yml up -d     # monitorización
```

PMM se abre en **https://localhost:8443** (usuario `admin`, contraseña `CursoMongo2026`; el aviso del certificado es normal).

## 7. Otros entornos

| Entorno | Carpeta | Arranque |
|---------|---------|----------|
| Día 1 (standalone y upgrade) | `dia1` | `docker compose up -d solo legacy toolbox` |
| Percona Server (laboratorio 10) | `dia3\lab10-auditoria-cifrado` | `docker compose up -d` |

## 8. Apagar al terminar el día

```powershell
cd entorno
docker compose -f compose.yml -f compose.pbm.yml -f compose.pmm.yml stop
```

Al día siguiente basta con `docker compose up -d` (o `reparar-entorno.bat` si algo no va).

## 9. Volver a empezar desde cero (solo si lo quieres de verdad)

```powershell
cd entorno
docker compose -f compose.yml -f compose.pbm.yml -f compose.pmm.yml down -v
```

Y después `levantar-todo.bat`. Esto borra todos los datos del replica set, PBM y PMM.
