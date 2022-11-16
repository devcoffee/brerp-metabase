SELECT
    bp.Name as cliente,
    SUM(ol.QtyReserved * ol.PriceEntered) as valor_saldo_entregar
FROM
    C_OrderLine ol
LEFT JOIN
    C_Order o ON o.C_Order_ID = ol.C_Order_ID
LEFT JOIN
    C_BPartner bp ON bp.C_BPartner_ID = o.C_BPartner_ID
WHERE
    o.IsSoTrx= 'Y'
AND
    o.DocStatus = 'CO'
AND
    o.cof_ExibirEmRelatorios = 'Y'
AND
    ol.QtyReserved > 0
GROUP BY
    cliente
ORDER BY
    valor_saldo_entregar DESC
LIMIT 50
