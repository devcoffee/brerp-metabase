select
    CASE
        WHEN oi.issotrx = 'Y' THEN
            'Pagar'
        ELSE
            'Receber'
    END as Tipo,
    CASE
        WHEN oi.daysdue > 120 THEN
            '121+ vencido'
        WHEN oi.daysdue > 45 AND oi.daysdue < 121 THEN
            '46-120 vencido'
        WHEN oi.daysdue > 15 AND oi.daysdue < 46 THEN
            '16-45 vencido'
        WHEN oi.daysdue > 0  AND oi.daysdue < 16 THEN
            '1-15 vencido'
        WHEN oi.daysdue = 0 THEN
            'hoje'
        WHEN oi.daysdue < -120 THEN
            '121+ à vencer'
        WHEN oi.daysdue < -45 AND oi.daysdue > -121 THEN
            '46-120  à vencer'
        WHEN oi.daysdue < -15 AND oi.daysdue > -46 THEN
            '16-45  à vencer'
        WHEN oi.daysdue < 0  AND oi.daysdue > -16 THEN
            '1-15 à vencer'
        ELSE
            'N/D: ' || oi.daysdue
    END as aging,
    sum(oi.openamt) as valoraberto
FROM
    rv_openitem oi 
WHERE
    oi.cof_ComposesCashFlow = 'Y'
GROUP BY
    aging, Tipo
ORDER BY 
    aging, Tipo
