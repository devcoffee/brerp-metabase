SELECT
    cof_getreflistvalue('M_Production','DocStatus',p.docstatus) as estado,
    to_char(p.movementdate, 'MM/YYYY') as mes,
    count(*) as quantidade_op
FROM
    M_Production p
WHERE
    p.movementdate > now() - INTERVAL '3 months'
AND
    p.movementdate < date_trunc('month', CURRENT_DATE)
GROUP BY
    mes, estado
ORDER BY
    mes, estado
    
