FROM debian:bookworm-slim

COPY install.sh /app/install.sh
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash git curl wget unzip tzdata openssl ca-certificates \
    iproute2 iputils-ping net-tools procps \
    && rm -rf /var/lib/apt/lists/*

# TCP tuning for lower latency
RUN echo "net.core.rmem_max=26214400"           >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.core.wmem_max=26214400"           >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.core.rmem_default=1048576"        >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.core.wmem_default=1048576"        >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.core.netdev_max_backlog=16384"    >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.ipv4.tcp_fastopen=3"              >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.ipv4.tcp_no_metrics_save=1"       >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.ipv4.tcp_timestamps=1"            >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.ipv4.tcp_sack=1"                  >> /etc/sysctl.d/99-gaming.conf && \
    echo "net.ipv4.tcp_congestion_control=bbr"  >> /etc/sysctl.d/99-gaming.conf

COPY config.json /etc/config.json

RUN chmod +x /app/install.sh && /app/install.sh

CMD ["sh", "-c", "sysctl --system >/dev/null 2>&1 || true && exec /usr/local/bin/xray -c /etc/config.json"]
