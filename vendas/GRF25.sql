SELECT
    p.Name as produto,
    SUM((ol.QtyEntered - ol.QtyLostSales) * ol.PriceEntered) as valor_liquido_vendas
FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID
WHERE
    o.dateordered > now() - INTERVAL '3 months'
AND
    o.dateordered >= date_trunc('month', CURRENT_DATE)
AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
GROUP BY
    produto
ORDER BY
    valor_liquido_vendas desc
LIMIT 50
    
