SELECT
    to_char(o.dateordered, 'MM/YYYY') as mes,
    SUM(ol.QtyEntered * ol.PriceEntered) as valor_total_comprado,
    SUM(ol.QtyReserved * ol.PriceEntered) as valor_pendente_entrega,
    SUM(
        CASE WHEN o.DocStatus = 'CO' AND (ol.QtyEntered > ol.QtyInvoiced) THEN
            (ol.QtyEntered - ol.QtyEntered) *  ol.PriceEntered         
        ELSE
            0
        END
    ) as valor_pendente_faturar,
    SUM(
        (ol.QtyEntered - (
                            CASE 
                                WHEN o.DocStatus = 'CL' AND (ol.QtyEntered > ol.QtyEntered) THEN 
                                    ol.QtyDelivered - ol.QtyEntered 
                                ELSE 
                                    0 
                            END
                        )
        ) * ol.PriceEntered
    ) as valor_liquido_compras,
    SUM(
        (
            CASE WHEN o.Docstatus = 'CL' AND ol.QtyEntered > ol.QtyDelivered THEN
                (ol.QtyDelivered - ol.QtyEntered) * ol.PriceEntered
            ELSE
                0
            END
        ) * ol.PriceEntered
    ) as valor_compra_nao_entregue,
    count(*) as quantidade_pedido_compra,
    count(distinct o.c_bpartner_id) as quantidade_fornecedores
FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
WHERE
    o.dateordered > now() - INTERVAL '3 months'
AND
    o.dateordered < date_trunc('month', CURRENT_DATE)
AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'N'
GROUP BY
    mes
ORDER BY
    mes
