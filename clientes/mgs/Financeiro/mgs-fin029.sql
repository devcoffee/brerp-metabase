/*
######################################################################################################################################
GRAFICO: Títulos Bancários por Tipo carteira   
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista os itens AR que estão alocados em operações bancárias classificando  nos tipos de carteira (descontada, simples, viculada etc)
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.Tradado operações 
em multimoeda.
######################################################################################################################################
*/

select
    cibank.name as InteBanco,
    (select t.Name from ad_ref_list_trl t left join ad_ref_list l on t.ad_ref_list_id = l.ad_ref_list_id
             where l.AD_Reference_ID='1500231' and l.value=oi.cof_BillFoldType and t.ad_language = 'pt_BR') as tipoCarteira,
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
    END) as valor_vencido,
    sum(oi.cof_openamtconverted) as total
FROM
    rv_openitem oi 
LEFT JOIN
    COF_C_BankIntegration cibank On cibank.COF_C_BankIntegration_ID = oi.COF_C_BankIntegration_ID
WHERE
    oi.issotrx = 'Y'
AND
    oi.COF_C_BankIntegration_ID is not null
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
    InteBanco,tipoCarteira
ORDER BY
     InteBanco,tipoCarteira