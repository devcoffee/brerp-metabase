/*
######################################################################################################################################
GRAFICO:Contas Receber através Boleto sem Atribuição - Dt. Faturada < Hoje
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista contas a receber em aberto, que possuem custódia indicativa de cobrança por CNAB  e que não estejam amarradas em 
nenhuma operação com emissão de CNAB, listando itens com  data de faturamento  anterior ao dia corrente
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

select
    bp.name,
    c.name as custodia,
    SUM(CASE
        WHEN oi.daysdue <= 0 then
            oi.cof_openamtconverted
        ELSE
            0
    END) as valor_vencer,
    SUM(CASE
        WHEN oi.daysdue > 0 then
            oi.cof_openamtconverted
        ELSE
            0
    END) as valor_vencido
FROM
    rv_openitem oi 
LEFT JOIN
    cof_c_custody c On c.cof_c_custody_id = oi.cof_c_custody_id
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = oi.c_bpartner_id
WHERE
    oi.issotrx = 'Y'
and
  c.cof_isGenerateCNAB='Y'
and 
     oi.DateInvoiced <  trunc(now() + interval '1 day')
and 
  oi.cof_bankintegrationname is null
and
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
GROUP BY
    bp.name,
    custodia
ORDER BY
    bp.name,
    custodia