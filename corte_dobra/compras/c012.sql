SELECT
   bp.name as parceiro,
   SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered) as valor_liquido_vendas

FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID
LEFT join 
    c_bpartner bp on bp.c_bpartner_id=o.c_bpartner_id 
left join 
    C_BPartner_Location ebp on  ebp.C_BPartner_Location_ID=o.C_BPartner_Location_ID
left join 
     C_Location ll on ll.C_Location_ID=ebp.C_Location_ID
left join 
    c_region rg on rg.c_region_id= ll.c_region_id   
left join 
    c_city ct on ct.c_city_id= ll.c_city_id   
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    o.issotrx='N'
AND
   p.IsStocked='Y'
and 
   p.ProductType='I'
and   
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
     parceiro
ORDER BY
    valor_liquido_vendas desc
