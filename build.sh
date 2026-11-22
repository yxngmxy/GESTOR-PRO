#!/usr/bin/env bash
# Compila y (opcionalmente) prueba SIN Maven. Requiere JDK 17+.
#   ./build.sh            -> compila a ./out
#   ./build.sh test JAR   -> compila y ejecuta las pruebas con junit-platform-console-standalone (ruta al .jar)
set -euo pipefail
cd "$(dirname "$0")"
rm -rf out out-test && mkdir -p out
javac -encoding UTF-8 -d out $(find src/main -name '*.java')
echo "Compilado en ./out"
if [ "${1:-}" = "test" ]; then
  JUNIT="${2:?Indique la ruta a junit-platform-console-standalone-*.jar}"
  mkdir -p out-test
  javac -encoding UTF-8 -cp "out:$JUNIT" -d out-test $(find src/test -name '*.java')
  java -jar "$JUNIT" -cp out:out-test --scan-classpath out-test --disable-banner
fi
