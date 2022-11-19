/*
######################################################################################################################################
GRAFICO: Devoluções e Créditos faturamento dia Corrente - Tipo Operação
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Apura a devolução do faturamento de mercadoria do dia, considerando apenas o valor de mercadoria(não inclui impostos não inclusos, fretes, despeesas e seguros),
 inclui apenas documentos que exibe de em relatórios e qie estejam completados ou fechados.
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

SELECT
    TDD.name as "Tipo Operação",
    sum(il.cof_linenetamtconverted*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
LEFT JOIN C_DocType tdd ON
    (tdd.c_doctype_id = i.c_doctypetarget_id)
LEFT JOIN
    rv_c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
where
    il.isdescription = 'N' 
and
    trunc(i.dateinvoiced) =trunc(now())
and 
    i.issotrx = 'Y'
and 
    i.docstatus IN ('CO','CL')
and 
    il.m_product_id > 0
and 
    i.cof_ExibirEmRelatorios = 'Y'
AND
   tdd.DocBaseType IN ('ARC' ) -- filtra tipo de documento Normal e devolução
AND
   i.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
group by 
  "Tipo Operação"
order by 
  valor_total desc
    
