SELECT
	to_char(o.dateordered, 'MM/YYYY') AS mes_estado,
    SUM(((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered)) as Venda_efetiva,
    SUM(((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * pr.weight)) as kilo_efetivo,
    SUM(((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * ol.PriceEntered))/ SUM(((ol.QtyEntered - ol.QtyLostSales - ol.cof_qtdanulada) * pr.weight)) as prc_medio,
    cof_getreflistvalue('C_OrderLine','Z_Morfologia',pr.Z_Morfologia) as Morfologia    --tabela que tem campo , o campo e o valor 
    
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
        o.docstatus in ('CO','CL')
    and 
        s.processed = 'N' -- valida que sessão esta ativa
    and 
        o.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
    and
        o.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
GROUP BY
	mes_estado,Morfologia
ORDER BY
	Morfologia,mes_estado