/*
######################################################################################################################################
GRAFICO:Rol de clientes em atraso >= 2 dias 
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Agrupa por cliente os valores em atraso >= 2dias, considerando apenas itens que compõem fluxo de caixa.
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

select
    bp.name,
    sum(oi.cof_openamtconverted) as "Valor Vencido"
FROM
    rv_openitem oi
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = oi.c_bpartner_id
WHERE
    oi.issotrx = 'Y'
AND
    oi.cof_ComposesCashFlow = 'Y'
AND 
    oi.cof_openamtconverted >0
AND 
     oi.daysdue > 1
AND 
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
    bp.name
ORDER BY
    "Valor Vencido" desc