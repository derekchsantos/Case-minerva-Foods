# Case minerva Foods

CASE ANALISTA DE SUSTENTAÇÃO – FOCO EM SRE

Durante a campanha “Semana do Churrasco”, a plataforma B2B/B2C de e‑commerce da Carnes S.A. recebeu um volume de tráfego 3‑4× maior que o normal. Por volta das 14:00 o time de monitoramento disparou alertas de alta latência na API de pagamentos, uso de CPU do banco de dados em 95 % e aumento de erros HTTP 504. Clientes corporativos (restaurantes, supermercados) e consumidores finais começaram a relatar impossibilidade de concluir pedidos.
Objetivo: Investigar a causa raiz, restaurar a operação do checkout o mais rápido possível e implementar mecanismos que evitem a recorrência do problema.

Ferramentas / Artefatos da analise 
1.2 Etapas de diagnóstico

Verificar health‑check da API de pagamentos: Status HTTP, latência, erros 5xx/504. 
curl, script de health‑check (ver seção 3).

Métricas de infraestrutura: CPU, memória, I/O do DB; taxa de requisições; latência da API. 
Grafana/Prometheus (dashboards já citados).

Logs da aplicação de checkout: Mensagens de timeout, exceções, stack traces. 
Loki/ELK, CloudWatch, arquivos de log.

Traces distribuídos: Identificar gargalo entre checkout → API de pagamentos → DB.
Jaeger, Zipkin, OpenTelemetry.

Consultas ao DB: Queries longas, locks, deadlocks, número de conexões.
pg_stat_activity, EXPLAIN ANALYZE.

Verificar fila de mensagens (se houver): Acúmulo de jobs de pagamento.
RabbitMQ/Kafka UI.
