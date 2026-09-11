#!/bin/bash
set -e

git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter pub get
flutter build web --release --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"