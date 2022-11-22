/*
######################################################################################################################################
GRAFICO:Contas Receber por Custódia
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS:  Lista os itens em Aberto AR, agrupando por custódia, classificando valores vencidos e a vencer  e que compõem fluxo caixa
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.Tradado operações 
em multimoeda.
######################################################################################################################################
*/

select
    c.name as custodia,
    SUM(CASE
        WHEN oi.daysdue <= 0 then
            oi.cof_openamtconverted
        ELSE
            0
    END) as valor_vencer,
    SUM(CASE
        WHEN oi.daysdue > 0 then
            oi.cof_openamtconverted
        ELSE
            0
    END) as valor_vencido
FROM
    rv_openitem oi 
LEFT JOIN
    cof_c_custody c On c.cof_c_custody_id = oi.cof_c_custody_id
WHERE
    oi.issotrx = 'Y'
and
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
GROUP BY
    custodia
ORDER BY
    custodia