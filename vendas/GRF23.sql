SELECT
    to_char(o.dateordered, 'MM/YYYY') || ' - ' || cof_getreflistvalue('C_Order','DocStatus',o.docstatus) as mes_estado,
    count(*) as quantidade_ordem_venda,
    count(distinct o.c_bpartner_id) as quantidade_clientes,
    SUM(ol.QtyEntered * ol.PriceEntered) as valor_total_vendas,
    SUM( 
        CASE WHEN (ol.QtyEntered - ol.QtyDelivered - ol.QtyLostSales) > 0 THEN
            (ol.QtyEntered - ol.QtyDelivered - ol .QtyLostSales) * ol.PriceEntered
        ELSE
            0
        END) as valor_pendente_entrega,
    SUM(
        CASE WHEN (ol.QtyEntered - ol.QtyInvoiced - ol.QtyLostSales) > 0 THEN
            (ol.QtyEntered - ol.QtyInvoiced - ol.QtyLostSales) * ol.PriceEntered
        ELSE
            0
        END) as valor_pendente_faturar,
    SUM((ol.QtyEntered - ol.QtyLostSales) * ol.PriceEntered) as valor_liquido_vendas,
    SUM(ol.QtyLostSales * ol.PriceEntered) as valor_vendas_perdidas

FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
WHERE
    o.dateordered > now() - INTERVAL '2 months'
AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
GROUP BY
    mes_estado
ORDER BY
    mes_estado
    
