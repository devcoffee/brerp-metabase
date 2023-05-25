/*
######################################################################################################################################
GRAFICO: Títulos Bancários por Tipo Integração
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
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}}  
WHERE
    oi.issotrx = 'Y'
AND
    oi.COF_C_BankIntegration_ID is not null
AND
    s.processed = 'N' -- valida que sessão esta ativa
and 
    oi.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    oi.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 

GROUP BY
    InteBanco,tipoCarteira
ORDER BY
     InteBanco,tipoCarteira