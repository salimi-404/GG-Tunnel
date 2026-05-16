#!/bin/sh

set -e

echo "📥 Downloading Xray Core v26.3.27..."
wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip

echo "📂 Installing Xray..."
unzip -o /tmp/xray.zip -d /tmp/xray_dist
chmod +x /tmp/xray_dist/xray
mv /tmp/xray_dist/xray /usr/local/bin/xray

echo "🧹 Cleaning up..."
rm -rf /tmp/xray.zip /tmp/xray_dist

echo "✅ Xray installed successfully!"

# ── Gaming Network Optimizations ──────────────────────────────────
echo "🎮 Applying gaming network optimizations..."

if modprobe tcp_bbr 2>/dev/null; then
  echo "tcp_bbr" >> /etc/modules-load.d/bbr.conf
  echo "net.core.default_qdisc=fq"            >> /etc/sysctl.d/99-gaming.conf
  echo "net.ipv4.tcp_congestion_control=bbr"  >> /etc/sysctl.d/99-gaming.conf
  echo "✅ BBR enabled"
else
  echo "⚠️  BBR not available, skipping"
fi

cat >> /etc/sysctl.d/99-gaming.conf << 'EOF'
net.ipv4.tcp_low_latency=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_keepalive_time=60
net.ipv4.tcp_keepalive_intvl=10
net.ipv4.tcp_keepalive_probes=6
net.ipv4.tcp_retries2=8
net.ipv4.tcp_syn_retries=3
net.core.rmem_max=4194304
net.core.wmem_max=4194304
net.ipv4.tcp_rmem=4096 87380 4194304
net.ipv4.tcp_wmem=4096 65536 4194304
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
EOF

sysctl -p /etc/sysctl.d/99-gaming.conf 2>/dev/null || true
echo "✅ Network tuning applied"

# ── UUID & Config ──────────────────────────────────────────────────
UUID=$(cat /proc/sys/kernel/random/uuid)
echo "🔑 Generated UUID: $UUID"
sed -i "s/__UUID__/$UUID/g" /etc/config.json

# ── Print configs script ───────────────────────────────────────────
cat > /usr/local/bin/print-configs.sh << 'SCRIPT'
#!/bin/sh
UUID=$(grep -o '"id": *"[^"]*"' /etc/config.json | head -1 | grep -o '[0-9a-f-]\{36\}')
SNI="${CODESPACE_NAME}-443.app.github.dev"
IRAN_TIME=$(TZ='Asia/Tehran' date +'%H:%M')

IPS="63.141.252.203 US1
142.54.178.211 US2
204.12.196.34 US3
50.7.87.2 DE1
50.7.87.5 DE2
50.7.87.4 DE3
138.201.54.122 DE4
94.130.50.12 DE5
94.130.13.19 DE6
50.7.87.3 DE7
85.10.207.48 DE8"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 G-Tunnel XHTTP H2 GAMING CONFIGS  |  ${IRAN_TIME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "$IPS" | while read IP LABEL; do
  echo "vless://${UUID}@${IP}:443?encryption=none&security=tls&type=xhttp&sni=${SNI}&path=%2Fxhttp-game&host=${SNI}&mode=auto#@Subioir DarkForce ${LABEL} H2 - ${IRAN_TIME}"
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔁 G-Tunnel WS FALLBACK CONFIGS  |  ${IRAN_TIME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "$IPS" | while read IP LABEL; do
  echo "vless://${UUID}@${IP}:443?encryption=none&security=tls&type=ws&sni=${SNI}&path=%2Flive-chat#@Subioir DarkForce ${LABEL} WS - ${IRAN_TIME}"
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SCRIPT

chmod +x /usr/local/bin/print-configs.sh
/usr/local/bin/print-configs.sh
