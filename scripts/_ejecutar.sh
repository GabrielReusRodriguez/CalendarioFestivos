#!/usr/bin/env bash
# Se usa con `source` desde los otros scripts. Ejecuta un comando en el
# repositorio, dentro del devcontainer si Flutter no está instalado.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Este archivo se usa con source desde los otros scripts." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${CALCULADORA_IMAGE:-calculadora-festivos-dev}"

ejecutar() {
  if command -v flutter >/dev/null 2>&1; then
    (cd "$ROOT" && "$@")
    return
  fi

  if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    docker build -t "$IMAGE" -f "$ROOT/.devcontainer/Dockerfile" "$ROOT/.devcontainer"
  fi

  mkdir -p "$ROOT/.container-home" "$ROOT/.pub-cache"
  local estado=0
  docker run --rm \
    -v "$ROOT:/workspace" \
    -w /workspace \
    -e HOME=/workspace/.container-home \
    -e PUB_CACHE=/workspace/.pub-cache \
    "$IMAGE" \
    "$@" || estado=$?

  if [[ "$(id -u)" != "0" ]]; then
    docker run --rm -v "$ROOT:/workspace" "$IMAGE" \
      chown -R "$(id -u):$(id -g)" /workspace/src /workspace/deploy /workspace/tests || true
  fi
  return "$estado"
}
