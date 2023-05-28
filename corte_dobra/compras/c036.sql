SELECT
    bp.name as fornecedor,
    SUM((ol.QtyEntered - ol.QtyLostSales) * ol.PriceEntered) as valor_liquido_vendas,
    to_char(o.dateordered, 'MM/YYYY') as mes
FROM
    C_Order o
LEFT JOIN
    AD_User u ON u.AD_User_ID = o.SalesRep_ID
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
left JOIN
    c_bpartner bp on bp.c_bpartner_id=o.c_bpartner_id
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 


WHERE

    o.DocStatus IN ('CO', 'CL')
AND 
    o.cof_ExibirEmRelatorios = 'Y'
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
    mes,fornecedor
ORDER BY
    mes,valor_liquido_vendas desc