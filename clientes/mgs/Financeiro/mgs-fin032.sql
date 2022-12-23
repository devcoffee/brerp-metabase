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
    sum(oi.cof_openamtconverted)
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
         (case WHEN {{TipoP}}='01' then 
                        oi.ad_org_id IN (1000001) 
           WHEN {{TipoP}}='02' then 
                        oi.ad_org_id IN (5000000) 
           WHEN {{TipoP}}='03' then 
                        oi.ad_org_id IN (5000004) 
           WHEN {{TipoP}}='98' then 
                        oi.ad_org_id IN (5000000,1000001) 
           else 
                        oi.ad_org_id IN (5000004,5000000,1000001)
        end ) 
        
GROUP BY
    bp.name,
    custodia
ORDER BY
    bp.name,
    custodia