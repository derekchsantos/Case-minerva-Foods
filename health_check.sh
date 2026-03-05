#!/usr/bin/env bash

# ------------------------------------------------------------
# Configurações
# ------------------------------------------------------------
URL="https://api.maiscarne.com/pagamentos/health"
LOG_FILE="health_check.log"
MAX_TIME_MS=500          # limite máximo de tempo de resposta em milissegundos

# ------------------------------------------------------------
# Função para escrever no log com timestamp
# ------------------------------------------------------------
log_alert() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $message" >> "$LOG_FILE"
}

# ------------------------------------------------------------
# Executa a requisição e captura status e tempo
# ------------------------------------------------------------
# -s : silencioso (não mostra barra de progresso)
# -o /dev/null : descarta o corpo da resposta
# -w "%{http_code} %{time_total}" : imprime código HTTP e tempo total em segundos
response=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" "$URL")
http_code=$(echo "$response" | awk '{print $1}')
time_sec=$(echo "$response" | awk '{print $2}')

# Converte o tempo para milissegundos (com duas casas decimais)
time_ms=$(awk "BEGIN {printf \"%.0f\", $time_sec * 1000}")

# ------------------------------------------------------------
# Avalia o resultado
# ------------------------------------------------------------
if [[ "$http_code" -ne 200 ]]; then
    log_alert "Código HTTP inesperado: $http_code (tempo de resposta: ${time_ms}ms)"
elif [[ "$time_ms" -gt "$MAX_TIME_MS" ]]; then
    log_alert "Tempo de resposta alto: ${time_ms}ms (código HTTP: $http_code)"
else
    # Opcional: registrar sucesso (pode ser comentado se não quiser logs de sucesso)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - OK: Endpoint saudável (HTTP 200, ${time_ms}ms)" >> "$LOG_FILE"
fi
