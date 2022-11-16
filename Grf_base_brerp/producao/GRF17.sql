SELECT
    cof_getreflistvalue('M_Production','DocStatus', p.DocStatus) as estado_documento,
    prod.name as produto,
    sum(pl.MovementQty) as qtd_producao
FROM
    M_Production p
LEFT JOIN
    M_ProductionLine pl ON pl.M_Production_ID = p.M_Production_ID AND pl.IsEndProduct='Y'
LEFT JOIN
    M_Product prod ON prod.M_Product_ID = pl.M_Product_ID
WHERE
    p.DocStatus IN ('CO','CL','IP')
AND
    p.movementdate > date_trunc('month', CURRENT_DATE)
GROUP BY
    estado_documento, produto
ORDER BY
    produto, estado_documento, qtd_producao desc
