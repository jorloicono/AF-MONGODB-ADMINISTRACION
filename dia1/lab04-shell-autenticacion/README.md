# Laboratorio 04 · mongosh a fondo y activación de la autenticación

**Duración:** 25 minutos · **Carpeta de trabajo:** `dia1/`

## Objetivos

Vas a usar `mongosh` de forma no interactiva y con scripts, a personalizarlo con un fichero `.mongoshrc.js` y, sobre todo, a activar el control de acceso en una instancia, crear el primer usuario administrador gracias a la *localhost exception* y comprobar que la instancia queda protegida.

## Parte A · mongosh como herramienta de administración

### A.1 Ejecución no interactiva

Desde el toolbox (`docker compose exec toolbox bash`):

```bash
mongosh "mongodb://solo:27017/tienda" --quiet --eval "db.pedidos.countDocuments({ estado: 'cancelado' })"
mongosh "mongodb://solo:27017/tienda" --quiet --json=relaxed --eval "db.clientes.findOne()"
```

La opción `--eval` es la base de cualquier script de operación: comprobaciones de salud, tareas programadas con `cron`, pasos de un playbook de Ansible...

### A.2 Personalizar el shell

```bash
cp /scripts/.mongoshrc.js ~/.mongoshrc.js
mongosh "mongodb://solo:27017/tienda"
```

```javascript
> tamanos()
> lentas(0)
> config.get("displayBatchSize")
> config.set("displayBatchSize", 5)
> db.pedidos.find()
> it
```

### A.3 Ayuda integrada y utilidades

```javascript
> help
> db.pedidos.help()
> db.pedidos.find().explain.help
> show collections
> db.stats({ scale: 1048576 })
> EJSON.stringify(db.clientes.findOne(), null, 2)
```

## Parte B · Activar la autenticación

### B.1 Comprueba que ahora mismo cualquiera puede hacer de todo

```bash
mongosh "mongodb://solo:27017" --quiet --eval "db.getSiblingDB('tienda').clientes.countDocuments()"
```

### B.2 Activa el control de acceso

Sal del toolbox. En tu equipo, edita `dia1/config/mongod.conf` y descomenta las dos últimas líneas para que queden así:

```yaml
security:
  authorization: enabled
```

Reinicia y comprueba en el log que no hay errores de sintaxis:

```bash
docker compose restart solo
docker compose logs --tail 20 solo
```

### B.3 Comprueba el efecto

Vuelve al toolbox y repite la consulta del paso B.1. ¿Qué ocurre?

### B.4 Crear el primer usuario: la localhost exception

No existe ningún usuario todavía. MongoDB permite, **solo desde localhost y solo mientras no exista ningún usuario**, crear el primero. Para eso tienes que conectarte desde el propio servidor:

```bash
docker compose exec solo mongosh
```

```javascript
> use admin
> db.createUser({
    user: "admin",
    pwd: passwordPrompt(),
    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, { role: "readWriteAnyDatabase", db: "admin" }, { role: "clusterAdmin", db: "admin" } ]
  })
```

Usa `CursoMongo2026` como contraseña. Ahora intenta crear un segundo usuario desde esa misma sesión sin autenticarte. ¿Qué pasa?

### B.5 Trabajar autenticado

Desde el toolbox:

```bash
mongosh "mongodb://admin:CursoMongo2026@solo:27017/?authSource=admin"
```

```javascript
> db.runCommand({ connectionStatus: 1 })
> use tienda
> db.clientes.countDocuments()
```

Crea un usuario de aplicación que solo pueda leer y escribir en `tienda`, y comprueba que no puede leer otras bases de datos:

```javascript
> use tienda
> db.createUser({ user: "app", pwd: "AppCurso2026", roles: [ { role: "readWrite", db: "tienda" } ] })
```

```bash
mongosh "mongodb://app:AppCurso2026@solo:27017/tienda?authSource=tienda" --eval "db.clientes.countDocuments(); db.getSiblingDB('admin').system.users.find().toArray()"
```

<details>
<summary>Ver solución</summary>

En el paso B.3 la conexión se establece (MongoDB acepta conexiones sin autenticar), pero cualquier comando que lea datos falla con `Command ... requires authentication` (código 13, `Unauthorized`). En el paso B.4, en cuanto existe el primer usuario, la localhost exception se cierra: un segundo `createUser` sin autenticarse falla. En el paso B.5 el usuario `app` puede contar documentos en `tienda`, pero la lectura de `admin.system.users` falla con `not authorized`. Fíjate en `authSource`: indica en qué base de datos está **definido** el usuario (`admin` para el administrador y `tienda` para `app`), que no tiene por qué coincidir con la base de datos con la que trabajas.

</details>

## Para terminar el día

```bash
docker compose stop
```

No borres los volúmenes: no son necesarios para el resto del curso, pero te permitirán repasar en casa.
