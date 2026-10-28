#!/bin/zsh
# Compila e instala em ~/Applications/NotaRapida.app (sem Dock, só barra de menus).
set -e
cd "$(dirname "$0")"
swift build -c release
APP=~/Applications/NotaRapida.app
pkill -x NotaRapida || true
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/NotaRapida "$APP/Contents/MacOS/"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>com.bryanbarroso.NotaRapida</string>
  <key>CFBundleName</key><string>Nota Rápida</string>
  <key>CFBundleExecutable</key><string>NotaRapida</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>15.0</string>
  <key>LSUIElement</key><true/>
  <key>NSServices</key><array><dict>
    <key>NSMenuItem</key><dict><key>default</key><string>Adicionar em Investigar</string></dict>
    <key>NSMessage</key><string>adicionarInvestigar</string>
    <key>NSPortName</key><string>NotaRapida</string>
    <key>NSSendTypes</key><array><string>NSStringPboardType</string></array>
    <key>NSKeyEquivalent</key><dict><key>default</key><string>^~i</string></dict>
  </dict></array>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
open "$APP"
# Faz o macOS enxergar o serviço novo sem precisar sair e entrar na sessão.
/System/Library/CoreServices/pbs -update
echo "Instalado em $APP"
