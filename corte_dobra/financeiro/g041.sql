select
    CASE
        WHEN oi.daysdue > 0THEN
            'Vencido'
        ELSE
            'Vencer'
    END as Tipo,
    CASE
        WHEN oi.daysdue > 90 THEN
            'Vencido maior 90'
        WHEN oi.daysdue > 45 AND oi.daysdue < 91 THEN
            'Vencido 46-90'
        WHEN oi.daysdue > 15 AND oi.daysdue < 46 THEN
            'Vencido 16-45'
        WHEN oi.daysdue > 0  AND oi.daysdue < 16 THEN
            'Vencido 1-15'
        WHEN oi.daysdue = 0 THEN
            'Hoje'
        WHEN oi.daysdue < -91 THEN
            'À vencer maior 90'
        WHEN oi.daysdue < -45 AND oi.daysdue > -91 THEN
            'À vencer 46-90'
        WHEN oi.daysdue < -15 AND oi.daysdue > -46 THEN
            'À vencer 16-45'
        WHEN oi.daysdue < 0  AND oi.daysdue > -16 THEN
            'À vencer 1-15'
        ELSE
            'N/D: ' || oi.daysdue
    END as aging,
    sum(oi.openamt) as valoraberto
FROM
    rv_openitem oi 
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    oi.cof_ComposesCashFlow = 'Y'
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    oi.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and 
   oi.issotrx='N'
and
    oi.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
GROUP BY
    aging, Tipo
ORDER BY 
    aging, Tipo
