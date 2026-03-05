#!/usr/bin/env bash
# ----------------------------------------------------------------------
# health_check.sh – verifica a saúde da API de pagamentos (+Carne)
# Requisitos: curl, date (GNU coreutils), awk
# ----------------------------------------------------------------------

# ----------- CONFIGURAÇÕES -------------------------------------------
URL="https://api.maiscarne.com/pagamentos/health"
MAX_LATENCY_MS=500                     # SLA máximo em milissegundos
LOG_FILE="health_check.log"
# ---------------------------------------------------------------------

# Função para escrever no log (inclui timestamp legível)
log_msg() {
    local level="$1"
    local msg="$2"
    printf "%s %-7s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$msg" >> "$LOG_FILE"
}

# ---------------------------------------------------------------------
# 1️⃣  Medir tempo e obter código HTTP
#    -w "%{http_code}"   → devolve apenas o código de status
#    -o /dev/null        → descarta o corpo da resposta
#    -s                  → modo silencioso (sem barra de progresso)
#    -D -                → grava headers temporariamente (necessário para -w)
# ---------------------------------------------------------------------
START_NS=$(date +%s%N)                     # nanosegundos (precisão alta)

# Executa a requisição
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
END_NS=$(date +%s%N)

# Calcula latência em milissegundos
LATENCY_MS=$(( (END_NS - START_NS) / 1000000 ))

# ---------------------------------------------------------------------
# 2️⃣  Avaliar resultado
# ---------------------------------------------------------------------
if [[ "$HTTP_CODE" -ne 200 ]] || (( LATENCY_MS > MAX_LATENCY_MS )); then
    # Monta mensagem de alerta
    ALERT_MSG="ALERTA – status=${HTTP_CODE} latency=${LATENCY_MS}ms (limite=${MAX_LATENCY_MS}ms)"
    log_msg "WARN" "$ALERT_MSG"
else
    # Opcional: registrar OK (pode ser comentado para reduzir ruído)
    INFO_MSG="OK – status=200 latency=${LATENCY_MS}ms"
    log_msg "INFO" "$INFO_MSG"
fi
