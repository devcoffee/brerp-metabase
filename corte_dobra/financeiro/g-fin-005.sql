/*
######################################################################################################################################
GRAFICO: Contas a receberD-7 até D+7
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista os itens em aberto a recer, convertidos para moeda corrente(R$), vencidos até 7 dias e a vencer até 7 dias  e que componham 
fluxo de caixa,descartando os  memorando de créditos (valor >0).
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
AND 
    oi.cof_openamtconverted >0
AND 
     (duedate > now()-7 and duedate < now() + 7 )
  
AND
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
