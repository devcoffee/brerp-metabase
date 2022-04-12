SELECT
    bp.Name as cliente,
    SUM(
        CASE
            WHEN (ol.QtyEntered - ol.QtyInvoiced - ol.QtyLostSales ) > 0 THEN
                 (ol.QtyEntered - ol.QtyInvoiced - ol.QtyLostSales) * ol.PriceEntered
            ELSE
                0
        END
    ) as valor_pendente_faturar
FROM
    C_Order o
LEFT JOIN
    C_BPartner bp ON bp.C_BPartner_ID = o.C_BPartner_ID
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
WHERE
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
AND 
    (ol.QtyEntered - ol.QtyInvoiced - ol.QtyLostSales) >0
GROUP BY
    cliente
ORDER BY
    valor_pendente_faturar desc, cliente
    
