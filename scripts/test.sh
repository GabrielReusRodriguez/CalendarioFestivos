#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_ejecutar.sh"

ejecutar bash -c 'set -euo pipefail
cd src
flutter pub get
flutter test
'
