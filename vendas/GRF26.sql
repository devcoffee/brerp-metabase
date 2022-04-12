SELECT
    to_char(o.dateordered, 'MM/YYYY') as mes,
    u.Name as vendedor,
    SUM((ol.QtyEntered - ol.QtyLostSales) * ol.PriceEntered) as valor_liquido_vendas
FROM
    C_Order o
LEFT JOIN
    AD_User u ON u.AD_User_ID = o.SalesRep_ID
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
WHERE
    o.dateordered > now() - INTERVAL '2 months'
AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
GROUP BY
    mes,vendedor
ORDER BY
    mes, valor_liquido_vendas desc, vendedor
    
