SELECT
    p.Name as produto,
    SUM(ol.QtyReserved * ol.PriceEntered) as valor_saldo_entregar
FROM
    C_OrderLine ol
LEFT JOIN
    C_Order o ON o.C_Order_ID = ol.C_Order_ID
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID
WHERE
    o.IsSoTrx= 'Y'
AND
    o.DocStatus = 'CO'
AND
    o.cof_ExibirEmRelatorios = 'Y'
AND
    ol.QtyReserved > 0
GROUP BY
    produto
ORDER BY
    valor_saldo_entregar DESC
LIMIT 50
