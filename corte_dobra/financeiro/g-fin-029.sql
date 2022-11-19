/*
######################################################################################################################################
GRAFICO: Títulos Bancários por Tipo Integração
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

select
    cibank.name as InteBanco,
    (select t.Name from ad_ref_list_trl t left join ad_ref_list l on t.ad_ref_list_id = l.ad_ref_list_id
             where l.AD_Reference_ID='1500231' and l.value=oi.cof_BillFoldType and t.ad_language = 'pt_BR') as tipoCarteira,
    SUM(CASE
        WHEN oi.daysdue <= 0 then
            oi.openamt
        ELSE
            0
    END) as valor_vencer,
    SUM(CASE
        WHEN oi.daysdue > 0 then
            oi.openamt
        ELSE
            0
    END) as valor_vencido,
    sum(oi.openamt) as total
FROM
    rv_openitem oi 
LEFT JOIN
    COF_C_BankIntegration cibank On cibank.COF_C_BankIntegration_ID = oi.COF_C_BankIntegration_ID
WHERE
    oi.issotrx = 'Y'
AND
    oi.COF_C_BankIntegration_ID is not null
AND
     oi.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
GROUP BY
    InteBanco,tipoCarteira
ORDER BY
     InteBanco,tipoCarteira