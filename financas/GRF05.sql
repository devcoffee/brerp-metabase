select
    c.name as custodia,
    SUM(CASE
        WHEN oi.daysdue <= 0 then
            oi.openamt
        ELSE
            0
    END) as valor_vencer,
    SUM(CASE
        WHEN oi.daysdue > 0 then
            oi.openamt
        ELSE
            0
    END) as valor_vencido
FROM
    rv_openitem oi 
LEFT JOIN
    cof_c_custody c On c.cof_c_custody_id = oi.cof_c_custody_id
WHERE
    oi.issotrx = 'Y'
AND
    oi.cof_ComposesCashFlow = 'Y'
GROUP BY
    custodia
ORDER BY
    custodia
