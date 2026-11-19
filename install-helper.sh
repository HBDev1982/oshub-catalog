#!/bin/bash
# One-time setup of the OSHub update helper, run from Terminal:
#   curl -fsSL https://raw.githubusercontent.com/HBDev1982/oshub-catalog/main/install-helper.sh | bash
# Terminal isn't subject to Gatekeeper, so this works where "Instalar OSHub"
# (downloaded with the DMG, quarantined) gets blocked. It:
#   1. clears the quarantine of the installed OSHub (so it opens without warnings)
#   2. installs the helper from the app itself as a LaunchAgent (127.0.0.1:47561)
#   3. checks that the helper answers
set -u
APP=""
for candidate in "/Applications/OSHub.app" "$HOME/Applications/OSHub.app"; do
    [ -d "$candidate" ] && APP="$candidate" && break
done
if [ -z "$APP" ]; then
    echo "❌ OSHub.app não encontrado em Aplicações. Instale-o primeiro."
    exit 1
fi
echo "🔓 A desbloquear $APP ..."
xattr -cr "$APP"

SRC="$APP/Contents/Resources/oshub-updater.sh"
if [ ! -f "$SRC" ]; then
    echo "❌ Esta versão do OSHub ainda não traz o assistente (precisa da 7.0.6 ou mais recente)."
    exit 1
fi
HELPER_DIR="$HOME/Library/Application Support/OSHubUpdater"
AGENT="$HOME/Library/LaunchAgents/com.overburnz.oshub.updater.plist"
mkdir -p "$HELPER_DIR" "$HOME/Library/LaunchAgents"
cp "$SRC" "$HELPER_DIR/oshub-updater.sh"
chmod +x "$HELPER_DIR/oshub-updater.sh"
cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>com.overburnz.oshub.updater</string>
    <key>ProgramArguments</key>
    <array><string>/bin/bash</string><string>$HELPER_DIR/oshub-updater.sh</string></array>
    <key>inetdCompatibility</key><dict><key>Wait</key><false/></dict>
    <key>Sockets</key>
    <dict>
        <key>Listener</key>
        <dict>
            <key>SockNodeName</key><string>127.0.0.1</string>
            <key>SockServiceName</key><string>47561</string>
            <key>SockType</key><string>stream</string>
        </dict>
    </dict>
</dict>
</plist>
PLIST
launchctl bootout "gui/$(id -u)/com.overburnz.oshub.updater" 2>/dev/null
launchctl bootstrap "gui/$(id -u)" "$AGENT"
sleep 1
if [ "$(echo PING | nc -w 3 127.0.0.1 47561)" = "PONG 1" ]; then
    echo "✅ Pronto. As próximas atualizações instalam-se dentro do OSHub, sem avisos."
else
    echo "⚠️  O assistente não respondeu. Envie esta janela ao programador."
fi
