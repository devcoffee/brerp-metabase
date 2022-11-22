/*
######################################################################################################################################
GRAFICO: Rol de Fornecedores em aberto - Geral
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Agrupa os valores em aberto de Itens AP, que compõem fluxo de caixa , tratando operações em multimoeda.
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
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
    oi.cof_openamtconverted >0
AND
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
GROUP BY
    bp.name
ORDER BY
    "Valor Aberto" desc