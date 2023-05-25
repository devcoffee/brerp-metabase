/*
######################################################################################################################################
GRAFICO:Cintas a receber vencendo hoje
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Agrupa os valores em aberto de Itens AR, que compõem fluxo de caixa , tratando operações em multimoeda e que vencem no dia
corrente. Descarta memorandos de crédito cliente.O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/


select
    bp.name,
    sum(oi.cof_openamtconverted) as "Valor Aberto"
FROM
    rv_openitem oi
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = oi.c_bpartner_id
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    oi.issotrx = 'Y'
AND
    oi.cof_ComposesCashFlow = 'Y'
AND 
    oi.cof_openamtconverted >0
AND 
    oi.daysdue=0
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    oi.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    oi.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 

    
GROUP BY
    bp.name
ORDER BY
    "Valor Aberto" desc