#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != Darwin ]]; then
  echo 'Build iOS memerlukan macOS dan Xcode.' >&2
  exit 1
fi
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter analyze --no-pub
flutter test --no-pub
flutter build ios --simulator --debug --no-codesign --no-pub \
  --dart-define="BUILD_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
plutil -lint ios/Runner/Info.plist ios/Runner/PrivacyInfo.xcprivacy \
  ios/Runner/en.lproj/InfoPlist.strings ios/Runner/id.lproj/InfoPlist.strings
echo 'Simulator app: build/ios/iphonesimulator/Runner.app'
