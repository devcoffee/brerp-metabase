SELECT
    r.name as UF,
    sum(il.linenetamt*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
LEFT JOIN
    c_bpartner_location bpl ON bpl.c_bpartner_location_id = i.c_bpartner_location_id
LEFT JOIN
    c_location l ON l.c_location_id = bpl.c_location_id
LEFT JOIN 
    c_region r ON r.c_region_id = l.c_region_id
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
    UF
order by
    valor_total desc
