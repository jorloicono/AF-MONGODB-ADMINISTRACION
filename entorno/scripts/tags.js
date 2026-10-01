// tags.js - Aplica los tags del laboratorio 06 (necesarios en la parte E del laboratorio 07)
// Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/tags.sh
const cfg = rs.conf();
const tags = { "mongo1:27017": { dc: "madrid", uso: "oltp" },
               "mongo2:27017": { dc: "madrid", uso: "oltp" },
               "mongo3:27017": { dc: "barcelona", uso: "informes" } };
cfg.members.forEach(m => { if (tags[m.host]) m.tags = tags[m.host]; });
printjson(rs.reconfig(cfg).ok);
rs.conf().members.forEach(m => print(m.host + "  " + JSON.stringify(m.tags)));
