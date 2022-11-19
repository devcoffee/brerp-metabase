/*
######################################################################################################################################
GRAFICO: Contas a Pagar vencendo hoje
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: fetua a somatória de todos os  itens em aberto AP, agrupado por parceiro de negócio, vendoendo no dia corrente e considerando os registros que consideream compõem fluxo de caixa 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/

select
    bp.name,
    sum(oi.cof_openamtconverted) as "Valor Aberto"
FROM
    rv_openitem oi
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = oi.c_bpartner_id
WHERE
    oi.issotrx = 'N'
AND
    oi.cof_ComposesCashFlow = 'Y'
AND 
    oi.cof_openamtconverted >0 -- desconsidera memorando de créditos 
AND 
     oi.daysdue=0
AND
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
GROUP BY
    bp.name
ORDER BY
    "Valor Aberto" desc