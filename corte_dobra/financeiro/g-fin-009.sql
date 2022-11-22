/*
######################################################################################################################################
GRAFICO: Contas a receber  (Risco)
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS:Efetua a somatória de todos os  itens em aberto AR, considerando os registros que consideream compõem fluxo de caixa 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda
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
