SELECT
    to_char(i.dateinvoiced, 'MM/YYYY') as mes,
    count(distinct i.c_bpartner_id) as qtd_clientes,
    count(distinct il.m_product_id) as qtd_produtos,
    sum(il.linenetamt*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
where
    i.dateinvoiced > now() - INTERVAL '2 months'
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
    mes
order by
    mes
