#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_ejecutar.sh"

ejecutar bash -c 'set -euo pipefail
cd src
flutter pub get
flutter build web --release
cd /workspace
rm -rf deploy/web
mkdir -p deploy/web
cp -a src/build/web/. deploy/web/
touch deploy/web/.gitkeep
echo "Web lista en deploy/web"
'
