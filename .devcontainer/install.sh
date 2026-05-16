#!/bin/sh

set -e

XRAY_VERSION="26.3.27"

echo "📥 Downloading Xray Core v${XRAY_VERSION}..."
wget -q --show-progress -O /tmp/xray.zip \
  "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip"

echo "📂 Installing Xray..."
unzip -o /tmp/xray.zip -d /tmp/xray_dist
chmod +x /tmp/xray_dist/xray
mv /tmp/xray_dist/xray /usr/local/bin/xray

echo "🧹 Cleaning up..."
rm -rf /tmp/xray.zip /tmp/xray_dist

echo "✅ Xray installed: $(xray version | head -1)"

# Generate UUID
UUID=$(cat /proc/sys/kernel/random/uuid)
echo "🔑 UUID: $UUID"

# Patch config
sed -i "s/__UUID__/$UUID/g" /etc/config.json

# ─── Server list ──────────────────────────────────────────────────
US_SERVERS="US1|63.141.252.203 US2|142.54.178.211 US3|204.12.196.34"
DE_SERVERS="DE1|50.7.87.2 DE2|50.7.87.5 DE3|50.7.87.4 DE4|138.201.54.122 DE5|94.130.50.12 DE6|94.130.13.19 DE7|50.7.87.3 DE8|85.10.207.48"
ALL_SERVERS="$US_SERVERS $DE_SERVERS"

# ─── print-configs.sh ─────────────────────────────────────────────
cat > /usr/local/bin/print-configs.sh << 'SCRIPT'
#!/bin/sh

UUID=$(grep -o '"id": *"[^"]*"' /etc/config.json | grep -o '[0-9a-f-]\{36\}' | head -1)
SNI="${CODESPACE_NAME}-443.app.github.dev"
IRAN_TIME=$(TZ='Asia/Tehran' date +'%H:%M')
US_SERVERS="US1|63.141.252.203 US2|142.54.178.211 US3|204.12.196.34"
DE_SERVERS="DE1|50.7.87.2 DE2|50.7.87.5 DE3|50.7.87.4 DE4|138.201.54.122 DE5|94.130.50.12 DE6|94.130.13.19 DE7|50.7.87.3 DE8|85.10.207.48"
ALL_SERVERS="$US_SERVERS $DE_SERVERS"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮  G-Tunnel Gaming  |  $(date +'%Y-%m-%d')  |  ساعت ایران: ${IRAN_TIME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for entry in $ALL_SERVERS; do
  LABEL=$(echo "$entry" | cut -d'|' -f1)
  IP=$(echo "$entry" | cut -d'|' -f2)
  echo ""
  echo "vless://${UUID}@${IP}:443?encryption=none&security=tls&type=ws&sni=${SNI}&path=%2Flive-chat#G-Tunnel ${LABEL} - ${IRAN_TIME}"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 برای پیدا کردن سریع‌ترین سرور:  ping-test.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SCRIPT

chmod +x /usr/local/bin/print-configs.sh

# ─── ping-test.sh ─────────────────────────────────────────────────
cat > /usr/local/bin/ping-test.sh << 'SCRIPT'
#!/bin/sh

SERVERS="US1|63.141.252.203 US2|142.54.178.211 US3|204.12.196.34 DE1|50.7.87.2 DE2|50.7.87.5 DE3|50.7.87.4 DE4|138.201.54.122 DE5|94.130.50.12 DE6|94.130.13.19 DE7|50.7.87.3 DE8|85.10.207.48"

echo ""
echo "🏓 Ping Test — کمترین ms = بهترین برای گیمینگ"
echo "────────────────────────────────────────────────"

BEST_LABEL=""; BEST_MS=99999

for entry in $SERVERS; do
  LABEL=$(echo "$entry" | cut -d'|' -f1)
  IP=$(echo "$entry" | cut -d'|' -f2)
  MS=$(ping -c 3 -W 2 "$IP" 2>/dev/null | awk -F'/' 'END{if($5) printf "%.1f", $5; else print "9999"}')
  if [ "$MS" = "9999" ]; then
    printf "  %-4s  %-18s  ❌ timeout\n" "$LABEL" "$IP"
  else
    printf "  %-4s  %-18s  %s ms\n" "$LABEL" "$IP" "$MS"
    if awk "BEGIN{exit !($MS < $BEST_MS)}"; then
      BEST_MS="$MS"; BEST_LABEL="$LABEL"
    fi
  fi
done

echo "────────────────────────────────────────────────"
if [ -n "$BEST_LABEL" ]; then
  echo "🏆 بهترین سرور: $BEST_LABEL  ($BEST_MS ms)"
fi
echo ""
SCRIPT

chmod +x /usr/local/bin/ping-test.sh

echo ""
echo "✅ نصب کامل شد."
/usr/local/bin/print-configs.sh
