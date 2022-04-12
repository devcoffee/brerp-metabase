SELECT
    rco.cof_reason_title as motivo,
    SUM((ol.COF_QtdAnulada + ol.QtyLostSales) * ol.PriceEntered) as valor_total_perdido
FROM
    C_Order o
LEFT JOIN
    COF_Reason_Closing_Order rco ON rco.COF_Reason_Closing_Order_ID = o.COF_Reason_Closing_Order_ID
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
WHERE
    o.dateordered > now() - INTERVAL '3 months'
AND
    o.dateordered >= date_trunc('month', CURRENT_DATE)
AND
    o.DocStatus IN ('CL', 'VO')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
GROUP BY
    motivo
ORDER BY
    valor_total_perdido DESC
    
