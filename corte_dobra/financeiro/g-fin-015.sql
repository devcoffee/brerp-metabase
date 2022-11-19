/*
######################################################################################################################################
GRAFICO: Devoluções e Créditos  Faturamento dia corrente
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: : Apura a devolução de vendas de mercadoria do dia, considerando apenas o valor de mercadoria(não inclui impostos não inclusos, fretes, despeesas e seguros),
 inclui apenas documentos que exibe de em relatórios.O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratados para operações em multimoeda 
######################################################################################################################################
*/
SELECT
    --TDD.name as TDDname,
    bp.name as BPname,
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
--and 
--    il.linenetamt > 0
and 
    i.issotrx = 'Y'
and 
    i.docstatus IN ('CO','CL')
and 
    il.m_product_id > 0
and 
    i.cof_ExibirEmRelatorios = 'Y'
--AND 
-- il.m_product_id IS NOT NULL -- Faturas que possuem linha
AND
   tdd.DocBaseType IN ('ARC' ) -- filtra tipo de documento Normal e devolução
AND
   i.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
group by 
  BPname
order by 
  valor_total asc
    
