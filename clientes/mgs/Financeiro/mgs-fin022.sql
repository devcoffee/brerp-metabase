/*
######################################################################################################################################
GRAFICO: Rol de Clientes em aberto - Geral
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Agrupa os valores em aberto de Itens AR, que compõem fluxo de caixa , tratando operações em multimoeda. Descarta memorandos de crédito cliente.
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
    "Valor Aberto" desc