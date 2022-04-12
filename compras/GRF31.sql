SELECT
    p.Name as produto,
    SUM(ol.QtyReserved * ol.PriceEntered) as valor_pendente_entrega
FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID
WHERE
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'N'
AND
    (ol.QtyReserved * ol.PriceEntered) > 0
GROUP BY
    produto
ORDER BY
    valor_pendente_entrega desc
LIMIT 50
    
