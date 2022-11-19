/*
######################################################################################################################################
GRAFICO:Compras e obrigações lançadas dia Corrente - Tipo Operação
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

SELECT
    TDD.name as "Tipo de Operaçao",
    sum(il.cof_linenetamtconverted*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
--LEFT JOIN
--    c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
LEFT JOIN C_DocType tdd ON
    (tdd.c_doctype_id = i.c_doctypetarget_id)
LEFT JOIN
    rv_c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
where
    il.isdescription = 'N' 
and
    i.dateinvoiced =date_trunc('month',current_date)
--and 
--    il.linenetamt > 0
and 
    i.issotrx = 'N'
and 
    i.docstatus IN ('CO','CL')
--and 
--  il.m_product_id > 0
and 
    i.cof_ExibirEmRelatorios = 'Y'
--AND 
-- il.m_product_id IS NOT NULL -- Faturas que possuem linha
AND
   tdd.DocBaseType IN ('API' ) -- filtra tipo de documento Normal e devolução
AND
   i.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
group by 
  "Tipo de Operaçao"
order by 
  valor_total desc
    
