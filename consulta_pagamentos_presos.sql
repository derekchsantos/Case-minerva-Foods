SELECT
    p.pedido_id      AS id_pedido,
    c.email          AS email_cliente,
    ROUND(
        EXTRACT(EPOCH FROM (NOW() - p.data_atualizacao)) / 60.0,
        1
    )                AS minutos_desde_atualizacao
FROM pagamentos p
JOIN pedidos ped ON ped.id = p.pedido_id
JOIN clientes c  ON c.id = ped.cliente_id
WHERE p.status_pagamento = 'processando'
  AND EXTRACT(EPOCH FROM (NOW() - p.data_atualizacao)) > 300;
