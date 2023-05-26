SELECT
   u.name as representante,
   SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered) as valor_liquido_vendas,
   SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * p.weight) as kilo_vendas,
   SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered) /SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * p.weight) as prcmedio,
   sum(ol.qtyinvoiced  * ol.PriceEntered) as valor_faturado,
   sum(ol.qtydelivered * ol.PriceEntered) as valor_entregue
   
   
FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID
LEFT join 
    c_bpartner bp on bp.c_bpartner_id=o.c_bpartner_id
LEFT JOIN
    AD_User u ON u.AD_User_ID = o.SalesRep_ID
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    o.issotrx='Y'

AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
and 
    trunc(o.DateOrdered)>= {{datefrom}}
and 
    trunc(o.DateOrdered)<= {{dateto}}
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    o.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    o.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
GROUP BY
     representante
ORDER BY
    valor_liquido_vendas desc


