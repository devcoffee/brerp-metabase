SELECT
   coalesce(tpg.name,'')||' | ' ||coalesce(clp.name,'')|| ' | ' ||coalesce(grp.Name,'')  as classificacao,
   to_char(o.dateordered, 'MM/YYYY') AS mes_estado,
   SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered)/SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * (case when p.Weight=0 then 1 else p.Weight end)) as kiloMedio
 FROM
    C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
LEFT JOIN
    M_Product p ON p.M_Product_ID = ol.M_Product_ID 
LEFT JOIN 
   C_UOM uni ON uni.C_UOM_ID=p.C_UOM_ID    
left join 
    COF_ProductGroup grp on grp.COF_ProductGroup_ID=p.COF_ProductGroup_ID
left join
    cof_productclass clp on clp.cof_productclass_ID=p.cof_productclass_ID
left join 
    COF_ProductType tpg on tpg.COF_ProductType_ID=p.COF_ProductType_ID
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    o.issotrx='N'
AND
    o.dateordered >= date_trunc('year', CURRENT_DATE)
AND
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
and 
    p.IsStocked='Y'
and
    trunc(o.DateOrdered)>= {{datefrom}}
and 
   trunc(o.DateOrdered)<= {{dateto}}
and
   o.issotrx = 'N'
and 
   s.processed = 'N' -- valida que sessão esta ativa
and 
    o.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    o.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 

GROUP BY
   mes_estado,classificacao
ORDER BY
    mes_estado,classificacao asc
