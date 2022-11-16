SELECT
    to_char(io.movementdate, 'MM/YYYY') || ' - ' || cof_getreflistvalue('M_InOut','DocStatus',io.docstatus) as mes_estado,
    count(*) as quantidade_expedicao,
    count(distinct io.c_bpartner_id) as quantidade_clientes

FROM
    M_InOut io
WHERE
    io.movementdate > now() - INTERVAL '3 months'
AND
    io.movementdate < date_trunc('month', CURRENT_DATE)
AND
    io.DocStatus IN ('CO', 'CL', 'IP')
GROUP BY
    mes_estado
ORDER BY
    mes_estado
    
