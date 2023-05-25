/*
######################################################################################################################################
GRAFICO: Contas a receber (Risco)
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Efetua a somatória de todos os  itens em aberto AR, considerando os registros que consideream compõem fluxo de caixa 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/
select
  sum(oi.cof_openamtconverted)
   
FROM
    rv_openitem oi
LEFT JOIN --join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    oi.issotrx = 'Y'
AND
    oi.cof_ComposesCashFlow = 'Y'
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    oi.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    oi.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
