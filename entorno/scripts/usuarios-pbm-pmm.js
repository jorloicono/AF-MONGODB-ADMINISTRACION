// usuarios-pbm-pmm.js - Crea los roles y usuarios de PBM (lab 12) y PMM (lab 13)
// Uso (desde tu equipo, carpeta entorno/):  docker compose exec toolbox bash /scripts/usuarios.sh
const admin = db.getSiblingDB("admin");
function intenta(desc, f) {
  try { f(); print("OK  " + desc); }
  catch (e) { print("--  " + desc + ": " + (e.codeName || e.message) + " (probablemente ya existía)"); }
}
intenta("rol pbmAnyAction", () => admin.createRole({
  role: "pbmAnyAction", privileges: [{ resource: { anyResource: true }, actions: ["anyAction"] }], roles: [] }));
intenta("usuario pbmuser", () => admin.createUser({
  user: "pbmuser", pwd: "PbmCurso2026",
  roles: [{ db: "admin", role: "readWrite", collection: "" }, { db: "admin", role: "backup" },
          { db: "admin", role: "clusterMonitor" }, { db: "admin", role: "restore" }, { db: "admin", role: "pbmAnyAction" }] }));
intenta("rol pmmMonitor", () => admin.createRole({
  role: "pmmMonitor",
  privileges: [
    { resource: { db: "", collection: "" }, actions: ["dbHash", "find", "listIndexes", "listCollections", "collStats", "dbStats", "indexStats"] },
    { resource: { db: "", collection: "system.version" }, actions: ["find"] },
    { resource: { db: "", collection: "system.profile" }, actions: ["find", "dbStats", "collStats", "indexStats"] }],
  roles: [] }));
intenta("usuario pmm", () => admin.createUser({
  user: "pmm", pwd: "PmmCurso2026",
  roles: [{ db: "admin", role: "pmmMonitor" }, { db: "local", role: "read" },
          { db: "admin", role: "clusterMonitor" }, { db: "admin", role: "directShardOperations" }] }));
