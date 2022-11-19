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
where 
    trunc(DateDoc) >= trunc(now()) - interval '90 days' 
AND
    anc.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
ORDER BY
    anc.DateDoc desc