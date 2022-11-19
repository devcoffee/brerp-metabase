/*
######################################################################################################################################
GRAFICO: Contas a pagar em atraso >= 2 dias
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista os itens em aberto a pagar, convertidos para moeda corrente(R$), vencidos>=2 dias  e que componham fluxo de caixa, 
descartando os  memorando de créditos (valor >0).
O Filtro ocorre apenas pela empresa, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

select
  sum(oi.cof_openamtconverted)
   
FROM
    rv_openitem oi
WHERE
    oi.issotrx = 'N'
AND
    oi.cof_ComposesCashFlow = 'Y'
AND 
    oi.cof_openamtconverted >0
AND 
     oi.daysdue > 1 
AND
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
