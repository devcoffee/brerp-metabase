SELECT
    prod.name as produto,
    sum(pl.QtyUsed) as qtd_producao
FROM
    M_Production p
LEFT JOIN
    M_ProductionLine pl ON pl.M_Production_ID = p.M_Production_ID AND pl.IsEndProduct = 'N' AND pl.cof_IsByProduct='N' AND pl.cof_IsCoProduct = 'N'
LEFT JOIN
    M_Product prod ON prod.M_Product_ID = pl.M_Product_ID
WHERE
    p.DocStatus IN ('CO','CL')
AND
    p.movementdate > now() - INTERVAL '3 months'
AND
    p.movementdate < date_trunc('month', CURRENT_DATE)
GROUP BY
    produto
ORDER BY
    qtd_producao desc
    
