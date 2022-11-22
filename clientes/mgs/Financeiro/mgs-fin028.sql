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
    (case WHEN {{TipoP}}='01' then 
                        oi.ad_org_id IN (1000001) 
           WHEN {{TipoP}}='02' then 
                        oi.ad_org_id IN (5000000) 
           WHEN {{TipoP}}='03' then 
                        oi.ad_org_id IN (5000004) 
           WHEN {{TipoP}}='98' then 
                        oi.ad_org_id IN (5000000,1000001) 
           else 
                        oi.ad_org_id IN (5000004,5000000,1000001)
           end )     
GROUP BY
    custodia
ORDER BY
    custodia