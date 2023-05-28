SELECT
  tdd.name as tipoOperacao,
  SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered) as valor_liquido_vendas,
 -- SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) ) as qtd,
  SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * p.Weight) as qtd_kilos,
  SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered)/SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * (case when p.Weight=0 then 1 else p.Weight end)) as kiloMedio
 -- SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered)/SUM(ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) as VLMédio

FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID
LEFT JOIN C_DocType tdd ON
    (tdd.c_doctype_id = o.c_doctypetarget_id) --tipo de documento
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    o.issotrx='N'
AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    o.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    o.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
and 
   trunc(o.DateOrdered)>= {{datefrom}}
and 
   trunc(o.DateOrdered)<= {{dateto}}
GROUP BY
    tipoOperacao
ORDER BY
    valor_liquido_vendas asc
