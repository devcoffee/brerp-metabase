SELECT
    rco.cof_reason_title as motivo,
    coalesce(cb.name,'Não Classificado') as pn_que_perdeu,
    SUM((ol.COF_QtdAnulada + ol.QtyLostSales) * ol.PriceEntered) as "Valor Perdido"
FROM
    C_Order o
LEFT JOIN
    COF_Reason_Closing_Order rco ON rco.COF_Reason_Closing_Order_ID = o.COF_Reason_Closing_Order_ID
LEFT JOIN
    C_OrderLine ol ON ol.C_Order_Id = o.C_Order_Id
left join c_bpartner cb on cb.c_bpartner_id=o.cof_PNConcorrente_ID

LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}}  
    

WHERE
    o.DocStatus IN ('CL', 'VO')
AND   
    o.cof_ExibirEmRelatorios = 'Y'
And 
    o.COF_Reason_Closing_Order_ID is not null
And
    o.issotrx='Y'
and 
    trunc(o.DateOrdered)>= {{datefrom}}
and 
    trunc(o.DateOrdered)<= {{dateto}}
and 
    rco.cof_ExigirDadosPN='Y'
and
   s.processed = 'N' -- valida que sessão esta ativa
and 
    o.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    o.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
group by
   motivo,pn_que_perdeu
order by
  "Valor Perdido" desc