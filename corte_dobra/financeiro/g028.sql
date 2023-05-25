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
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    oi.issotrx = 'Y'
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    oi.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    oi.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 

GROUP BY
    custodia
ORDER BY
    custodia