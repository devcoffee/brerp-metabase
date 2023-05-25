SELECT
    TDD.name as "Tipo Operação",
    bp.name as nomepn,
    sum(il.cof_linenetamtconverted*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
LEFT JOIN C_DocType tdd ON
    (tdd.c_doctype_id = i.c_doctypetarget_id)
LEFT JOIN
    rv_c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}}     
where
    il.isdescription = 'N' 
and
    trunc(i.dateinvoiced) =trunc(now() - interval '1 day')
and 
    i.issotrx = 'Y'
and 
    i.docstatus IN ('CO','CL')

and 
    i.cof_ExibirEmRelatorios = 'Y'
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    i.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    i.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 


group by 
  "Tipo Operação",nomepn
order by 
   "valor_total" desc

    
