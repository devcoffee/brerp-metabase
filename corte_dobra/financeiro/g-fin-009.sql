/*
######################################################################################################################################
GRAFICO: Contas a receber em atraso (Risco)
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

select
  sum(oi.cof_openamtconverted)
   
FROM
    rv_openitem oi
WHERE
    oi.issotrx = 'Y'
AND
    oi.cof_ComposesCashFlow = 'Y'
--AND 
--    oi.cof_openamtconverted >0
--AND 
--     oi.daysdue > 3 
AND
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
