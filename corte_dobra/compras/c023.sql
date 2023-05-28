SELECT
    date_trunc('month', o.DateOrdered) as mescompra,
    sum((ol.QtyEntered - ol.QtyLostSales) * (currencyconvert(ol.priceentered, o.c_currency_id, 297::numeric, now()::date::timestamp with time zone, o.c_conversiontype_id, o.ad_client_id, o.ad_org_id))) as valorFaturar
FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 

WHERE
    o.DocStatus IN ('CO','CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
and 
   o.issotrx='N'
and
   ((o.DateOrdered >=date_trunc('month', CURRENT_DATE) - INTERVAL '1 month') AND (o.DateOrdered <= date_trunc('day', CURRENT_DATE) - INTERVAL '1 month') OR o.DateOrdered >=date_trunc('month', CURRENT_DATE))

and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    o.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    o.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 

--and 
--    trunc(o.DateOrdered)>= {{datefrom}}
--and 
--    trunc(o.DateOrdered)<= {{dateto}}
  
group by 
  mescompra
