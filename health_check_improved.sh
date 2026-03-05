#!/usr/bin/env bash
# -------------------------------------------------
# health_check_improved.sh
# Verifica a saúde da API de pagamentos (+Carne)
# - status HTTP 200 ?
# - latência <= LIMITE_LATENCIA_MS ?
# Registra alerta em health_check.log quando
# qualquer das duas condições falhar.
# -------------------------------------------------

# ==================== CONFIGURAÇÕES ====================
URL="https://api.maiscarne.com/pagamentos/health"   # endpoint a ser testado
LIMITE_LATENCIA_MS=500                              # SLA de latência (ms)
TIMEOUT_SEC=15                                      # timeout da requisição (s)
LOG_FILE="health_check.log"                         # arquivo de log
VERBOSE=false                                       # true → imprime no console
# =====================================================

# ---------- Função de log ----------
log_msg() {
    local level="$1"
    local msg="$2"
    local line="$(date '+%Y-%m-%d %H:%M:%S') $(printf '%-7s' "$level") $msg"
    echo "$line" >> "$LOG_FILE"
    $VERBOSE && echo "$line"
}

# ---------- Medir tempo e fazer a chamada ----------
START_NS=$(date +%s%N)   # nanosegundos (precisão alta)

# -s : silent (sem barra de progresso)
# -o /dev/null : descarta o corpo da resposta
# -w "%{http_code}" : devolve apenas o código HTTP
# --max-time : timeout da requisição
# 2>&1 captura stderr (mensagens de erro do curl)
CURL_OUTPUT=$(curl -s -o /dev/null -w "%{http_code}" \
                --max-time "$TIMEOUT_SEC" "$URL" 2>&1)

END_NS=$(date +%s%N)

# Código HTTP (pode ser 000 quando não há resposta)
HTTP_CODE=$(echo "$CURL_OUTPUT" | head -n1)

# Mensagem de erro do curl (se houver)
CURL_ERROR=$(echo "$CURL_OUTPUT" | tail -n +2 | tr '\n' ' ' | sed 's/^[[:space:]]*//')

# Latência em milissegundos
LATENCY_MS=$(( (END_NS - START_NS) / 1000000 ))

# ---------- Avaliar condições ----------
if [[ "$HTTP_CODE" -ne 200 ]] || (( LATENCY_MS > LIMITE_LATENCIA_MS )); then
    # Monta a mensagem de alerta
    ALERT="ALERTA – status=${HTTP_CODE:-000} latency=${LATENCY_MS}ms (limite=${LIMITE_LATENCIA_MS}ms)"
    # Acrescenta detalhe do curl, se houver
    [[ -n "$CURL_ERROR" ]] && ALERT="${ALERT} | detalhe: ${CURL_ERROR}"
    log_msg "WARN" "$ALERT"
else
    # Mensagem de sucesso (pode ser silenciada se preferir)
    log_msg "INFO" "OK – status=200 latency=${LATENCY_MS}ms"
fi
