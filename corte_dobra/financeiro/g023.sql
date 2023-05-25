/*
######################################################################################################################################
GRAFICO:Pagamentos Realizados - D -1
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Pagamentos AP que foram realizado no dia anterior ao corrente, tratando as operações multimoedas e filtrando documentos 
completados e fechados. São descartados operações onde o TDD refere-se a operações de transferência entre contas 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

SELECT 
    bp.name,
    sum( currencyconvert(pay.payamt , pay.c_currency_id, 297::numeric, pay.datetrx::date::timestamp with time zone, pay.c_conversiontype_id, pay.ad_client_id, pay.ad_org_id)) as "Pagamentos Dia"

FROM
    C_Payment pay
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = pay.c_bpartner_id
LEFT JOIN C_DocType tdd ON
    tdd.c_doctype_id = pay.c_doctype_id
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    pay.docstatus in ('CO', 'CL') 
AND 
    pay.isreceipt  = 'N' 
AND
    trunc(pay.datetrx)  = trunc(now()) - interval '1 days'
AND 
    tdd.cof_DocTypeBankTransfer='N'
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    pay.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    pay.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 

GROUP BY
    bp.name
ORDER BY
    "Pagamentos Dia" desc