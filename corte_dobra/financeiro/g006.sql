/*
######################################################################################################################################
GRAFICO: Contas a receber em atraso >= 2 dias
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista os itens em aberto a pagar, convertidos para moeda corrente(R$), vencidos >=2 dias e que componham fluxo de caixa,
descartando os  memorando de créditos (valor >0).
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações. Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/


select
  sum(oi.cof_openamtconverted)
   
FROM
    rv_openitem oi
--  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
LEFT JOIN
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    oi.issotrx = 'Y'
AND
    oi.cof_ComposesCashFlow = 'Y'
AND 
    oi.cof_openamtconverted >0
AND 
     oi.daysdue >1 
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    oi.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    oi.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
