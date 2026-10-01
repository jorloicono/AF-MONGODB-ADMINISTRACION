# Administración de MongoDB: operación, alta disponibilidad, seguridad y monitorización

Repositorio de laboratorios del curso de **administración de MongoDB** (16 horas, 4 sesiones de 4 horas). Aquí tienes todo lo necesario para hacer las prácticas en tu propio equipo usando **Docker**, sin instalar MongoDB en el sistema operativo.

El objetivo del curso es que salgas sabiendo operar MongoDB en el día a día: poner en marcha instancias nuevas, configurar la replicación y la alta disponibilidad, protegerlas, hacer copias de seguridad y restaurarlas, monitorizarlas y resolver problemas.

## Guía para el instructor

**[GUIA-ENTORNO.md](GUIA-ENTORNO.md)** explica cómo arrancar, reparar y apagar el entorno en Windows, y recoge los problemas conocidos con su solución. Para dejar todo en marcha de una vez: doble clic en `levantar-todo.bat`; si algo falla: `reparar-entorno.bat`.

## Antes del primer día

Sigue la guía **[00-preparacion](00-preparacion/README.md)**. Es imprescindible tener Docker funcionando y las imágenes descargadas antes de empezar: descargarlas todas durante la clase, con veinte personas en la misma red, puede llevar mucho tiempo.

## Estructura del repositorio

```text
.
├── 00-preparacion/        Instalación de Docker y verificación del entorno
├── presentaciones/        Diapositivas de los cuatro días (PowerPoint)
├── entorno/               Replica set de 3 nodos + toolbox (días 2, 3 y 4)
│   ├── compose.yml          Entorno base
│   ├── compose.tls.yml      Override para el laboratorio de TLS
│   ├── compose.pbm.yml      Override para Percona Backup for MongoDB
│   ├── compose.pmm.yml      Override para Percona Monitoring and Management
│   └── scripts/             Scripts compartidos (datos, carga, certificados...)
├── dia1/                  Fundamentos y administración básica
├── dia2/                  Replicación y alta disponibilidad
├── dia3/                  Seguridad
└── dia4/                  Backups, monitorización y troubleshooting
```

## Agenda y laboratorios

| Día | Bloque | Laboratorios |
|-----|--------|--------------|
| 1 | Fundamentos y administración básica | [01 Entorno y primer mongod](dia1/lab01-entorno/README.md) · [02 Actualización 7.0 → 8.0](dia1/lab02-actualizacion/README.md) · [03 Memoria, WiredTiger y SO](dia1/lab03-memoria-almacenamiento/README.md) · [04 mongosh y autenticación](dia1/lab04-shell-autenticacion/README.md) |
| 2 | Replicación y alta disponibilidad | [05 Replica set con keyfile](dia2/lab05-replica-set/README.md) · [06 Concerns, prioridades y tags](dia2/lab06-concerns-prioridades-tags/README.md) · [07 Failover, mantenimiento rolling y geodistribución](dia2/lab07-alta-disponibilidad/README.md) |
| 3 | Seguridad | [08 Usuarios, roles y límites](dia3/lab08-usuarios-roles/README.md) · [09 Migración a TLS y x.509](dia3/lab09-tls-x509/README.md) · [10 Auditoría y cifrado en reposo](dia3/lab10-auditoria-cifrado/README.md) |
| 4 | Backups, monitorización y troubleshooting | [11 mongodump y copias binarias](dia4/lab11-backup-nativo/README.md) · [12 Percona Backup for MongoDB y PITR](dia4/lab12-pbm/README.md) · [13 PMM y alertas](dia4/lab13-pmm/README.md) · [14 Resolución de incidencias](dia4/lab14-troubleshooting/README.md) |

## Convenciones de los laboratorios

Los comandos que empiezan por `docker compose` se ejecutan **en tu equipo** (PowerShell, Terminal de macOS o shell de Linux), situado en la carpeta que indique el laboratorio. Casi todo lo demás se ejecuta **dentro del contenedor `toolbox`**, que es un puesto de administración Linux con `mongosh` y las MongoDB Database Tools. Así los comandos son idénticos para todos, uses el sistema operativo que uses.

```bash
docker compose exec toolbox bash     # entras en el toolbox
mongosh "$RS"                        # dentro del toolbox: conexión al replica set como admin
```

**Si usas Windows con PowerShell:** algunos comandos del equipo filtran la salida con `grep` o `head`, que no existen en PowerShell. Sustituye `| grep -i texto` por `| Select-String texto`, `| grep -iE "a|b"` por `| Select-String "a|b"` y `| head -n 20` por `| Select-Object -First 20`. Todo lo que se ejecuta dentro de los contenedores funciona igual en cualquier sistema.

Los bloques marcados con `>` en los enunciados son comandos de `mongosh`. Las soluciones están plegadas bajo **Ver solución**: intenta resolver cada paso antes de abrirlas.

## Versiones utilizadas

| Componente | Imagen |
|------------|--------|
| MongoDB Community Server | `mongodb/mongodb-community-server:8.0-ubi9` (y `7.0-ubi9` para el upgrade) |
| Herramientas cliente | `mongo:8.0` (mongosh + MongoDB Database Tools) |
| Percona Server for MongoDB | `percona/percona-server-mongodb:8.0` (auditoría y cifrado en reposo) |
| Percona Backup for MongoDB | `percona/percona-backup-mongodb:2.15.0` |
| Percona Monitoring and Management | `percona/pmm-server:3` y `percona/pmm-client:3` |

Las credenciales que aparecen en los ficheros (`CursoMongo2026`, etc.) son **solo para el laboratorio**. Nunca reutilices estos ficheros tal cual en un entorno real.

## Limpieza al terminar el curso

```bash
cd entorno && docker compose -f compose.yml -f compose.pbm.yml -f compose.pmm.yml down -v
cd ../dia1 && docker compose down -v
cd ../dia3/lab10-auditoria-cifrado && docker compose down -v
```
