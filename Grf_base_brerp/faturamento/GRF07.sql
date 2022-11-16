SELECT
    p.name as produto,
    sum(il.linenetamt*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
LEFT JOIN
    M_product p ON p.M_Product_ID = il.M_Product_ID
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
    produto
order by
    produto
LIMIT 
    20
