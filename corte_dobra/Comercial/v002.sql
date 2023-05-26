SELECT
	to_char(o.dateordered, 'MM/YYYY') AS mes_estado,
	count(distinct o.C_Order_ID) AS quantidade_ordem_venda,
	count(distinct o.c_bpartner_ID) AS quantidade_clientes,
	
	SUM(ol.QtyEntered * pr.Weight) AS Carteira_vda_total,
	
	SUM(
	    CASE WHEN o.docstatus  in ('IP','DR') THEN
	   
	         (ol.QtyEntered * pr.Weight) 
	    ELSE
	      0
	   END) 
	    AS orcados_negociacao,
	
	SUM( 
      CASE WHEN (ol.QtyEntered - ol.QtyDelivered - ol.QtyLostSales) >0  and o.docstatus NOT in ('IP','DR')  THEN
           (ol.QtyEntered - ol.QtyDelivered - ol .QtyLostSales) * pr.Weight
       ELSE
          0
      END) AS vl_entregar,
	
	SUM(
      CASE WHEN (ol.QtyEntered - ol.QtyInvoiced - ol.QtyLostSales) >0 and o.docstatus NOT in ('IP','DR') THEN
         (ol.QtyEntered - ol.QtyInvoiced - ol.QtyLostSales) * pr.Weight
      ELSE
           0
      END) AS vl_faturar,
	
	SUM(
	    CASE WHEN o.docstatus NOT in ('IP','DR') THEN
	   
	         ((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * pr.Weight) 
	    ELSE
	      0
	   END) 
	    AS carteira_vendas_liquida,
	  SUM((ol.QtyLostSales + ol.cof_qtdanulada) * pr.Weight) AS Perdidas_anuladas,
	  
	  
	  
	  (SUM(
	  CASE WHEN o.docstatus NOT in ('IP','DR') THEN
	    ((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * pr.Weight) 
	  ELSE
	      0
	  END) /sUM(ol.QtyEntered *pr.Weight))
	AS efetividade,
     (sUM((ol.QtyLostSales + ol.cof_qtdanulada) * pr.Weight)/SUM(ol.QtyEntered * pr.Weight)) as perc_perdidos

FROM
	C_Order o
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
left join
    M_Product pr ON pr.M_Product_id=ol.M_Product_id
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
	    o.cof_ExibirEmRelatorios = 'Y'
	and 
	    trunc(o.DateOrdered)>= {{datefrom}}
	and 
	    trunc(o.DateOrdered)<= {{dateto}}
	and
        o.issotrx = 'Y'
    and 
        s.processed = 'N' -- valida que sessão esta ativa
    and 
        o.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
    and
        o.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
GROUP BY
	mes_estado
ORDER BY
	mes_estado