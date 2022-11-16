SELECT
    bp.Name as fornecedor,
    SUM((ol.QtyEntered - (
                            CASE WHEN o.DocStatus = 'CL' AND ol.QtyEntered > ol.QtyDelivered THEN
                                ol.QtyDelivered - ol.QtyEntered
                            ELSE
                                0
                            END
                         )
        ) * ol.PriceEntered
    ) as valor_liquido_compras
FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    C_BPartner bp ON bp.C_BPartner_ID = o.C_BPartner_ID
WHERE
    o.dateordered > now() - INTERVAL '3 months'
AND
    o.dateordered < date_trunc('month', CURRENT_DATE)
AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'N'
GROUP BY
    fornecedor
ORDER BY
    valor_liquido_compras desc
LIMIT 50
    
