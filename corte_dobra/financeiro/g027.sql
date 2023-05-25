/*
######################################################################################################################################
GRAFICO: Análises de créditos dos últimos 90 dias
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista as análises de créditos realizadas nos ultimos 90 dias exibindo os no dia da análise, concedidos na análise e atual
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

select
    to_char(anc.DateDoc,'dd/MM/yyyy') as "Data Analise",
    bp.name as "Parceiro",
    bp.totalopenbalance as "Saldo Aberto Atual",
    bp.SO_CreditLimit as "Limite Crédito Atual",
    anc.COF_LimiteCreditoAntigo"Antigo Limite Crédito",
    anc.SO_CreditLimit as "Limite Crédito Aprovado",
    anc.TotalOpenBalance as "Saldo em Aberto na Análise"
    
FROM
    COF_CreditAnalysis ANC
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = anc.c_bpartner_id
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
where 
    trunc(DateDoc) >= trunc(now()) - interval '90 days' 
   and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    anc.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    anc.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
    
ORDER BY
    anc.DateDoc desc