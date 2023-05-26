  SELECT
    p.Name as produto,
    SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered) as valor_liquido_vendas,
    SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) ) as qtd,
    SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * p.Weight) as qtd_kilos,
    SUM(
          (ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered)
                                                                                   /
                                                                                       CASE WHEN SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * (case when p.Weight=0 then 1 else p.Weight end))=0 THEN 1 
                                                                                       ELSE 
                                                                                           SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * (case when p.Weight=0 then 1 else p.Weight end)) END 
                                                                                       as kiloMedio,
   
   SUM((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered)/ CASE WHEN  SUM(ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada)=0 THEN 1 ELSE  SUM(ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) END as VLMédio,
   sum(ol.qtyinvoiced  * ol.PriceEntered) as valor_faturado,
   sum(ol.qtydelivered * ol.PriceEntered) as valor_entregue,
   uni.UOMSymbol Unidade
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
LEFT JOIN 
   C_UOM uni ON uni.C_UOM_ID=p.C_UOM_ID    

WHERE
    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
and 
    o.issotrx='Y'    
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
         produto,Unidade
ORDER BY
    valor_liquido_vendas desc

