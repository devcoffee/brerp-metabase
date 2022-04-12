SELECT
    bp.name as cliente,
    sum(il.linenetamt*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
where
    i.dateinvoiced > now() - INTERVAL '3 months'
and
    i.dateinvoiced < date_trunc('month', CURRENT_DATE)
and 
    il.isdescription = 'N' and il.linenetamt > 0
and 
    i.issotrx = 'Y'
and 
    i.docstatus IN ('CO','CL')
and 
    il.m_product_id > 0
and 
    i.cof_ExibirEmRelatorios = 'Y'
group by 
    cliente
order by
    valor_total desc
