SELECT
    u.name as representante_de_vendas,
    sum(il.linenetamt*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
LEFT JOIN
    ad_user u ON u.ad_user_id = i.SalesRep_ID
where
    i.dateinvoiced >= date_trunc('month', CURRENT_DATE)
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
    representante_de_vendas
order by
    valor_total desc
