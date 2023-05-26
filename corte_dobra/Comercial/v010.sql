SELECT
   to_char(ol.DatePromised,'dd-mm-yy') as dia,
   case when rge.name is not null then rge.value ||'-'|| rge.name  else 'REGIAO DE ENTREGA NAO CLASSIFICADA' end as regiao,
   sum((ol.qtyentered-ol.QtyLostSales) * p.Weight) as Peso,
   rge.cof_PesoMaximo as PesoMaximoRegiao,
   coalesce((rge.cof_PesoMaximo - sum((ol.qtyentered-ol.QtyLostSales) * p.Weight)),0) as saldoAlocar
FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID
LEFT JOIN 
   C_UOM uni ON uni.C_UOM_ID=p.C_UOM_ID    
LEFT join 
    c_bpartner bp on bp.c_bpartner_id=o.c_bpartner_id
left join 
    C_BPartner_Location ebp on  ebp.C_BPartner_Location_ID=o.C_BPartner_Location_ID
left join 
     COF_M_ShipRegion rge on rge.COF_M_ShipRegion_id= ebp.COF_M_ShipRegion_id 
left join 
     C_Location ll on ll.C_Location_ID=ebp.C_Location_ID
left join 
    c_region rg on rg.c_region_id= ll.c_region_id    
left join 
    c_city ct on ct.c_city_id= ll.c_city_id   
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    o.issotrx='Y'
AND
    ol.DatePromised >= trunc(CURRENT_DATE)
and 
    ol.DatePromised <= date_trunc('month',CURRENT_DATE + interval '60 days')
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

--and 
--    trunc(o.DateOrdered)>= {{datefrom}}
--and 
 --   trunc(o.DateOrdered)<= {{dateto}}
GROUP BY
     dia,regiao,PesoMaximoRegiao
     --,parceiro,cidname,cidcode, latitude,longitude, cidade, rgcode
ORDER BY
    dia asc
