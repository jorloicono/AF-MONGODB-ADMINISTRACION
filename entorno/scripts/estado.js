// estado.js - Resumen del replica set: estado, salud, lag y primario
// Uso (desde tu equipo):  docker compose exec toolbox bash /scripts/estado.sh
const st = rs.status();
const primario = st.members.find(m => m.stateStr === "PRIMARY");
print("Replica set: " + st.set + "   hora: " + new Date().toISOString());
st.members.forEach(m => {
  let lag = "";
  if (primario && m.stateStr === "SECONDARY" && m.optimeDate) {
    lag = "  lag: " + ((primario.optimeDate - m.optimeDate) / 1000).toFixed(0) + " s";
  }
  print("  " + m.name.padEnd(14) + (m.stateStr || "").padEnd(28) + " salud: " + m.health + lag);
});
print("Primario: " + (primario ? primario.name : "¡NINGUNO!"));
