SELECT
    st.name AS produto,
    SUM(st.qtyonhand) AS quantidade_disponivel,
    SUM(st.qtyonhand * COALESCE(c.currentcostprice,0)) AS valor_custo
FROM 
    rv_storage st 
LEFT JOIN
    M_Warehouse w ON w.M_Warehouse_ID = st.M_Warehouse_ID
LEFT JOIN
    C_AcctSchema acct on acct.ad_client_id = st.ad_client_id and acct.ad_org_id in (0,st.ad_org_id)
LEFT JOIN 
    M_Cost c ON st.m_product_id = c.m_product_id and c.M_CostElement_ID = (select MAX(ce.M_CostElement_ID) FROM M_CostElement ce WHERE ce.CostElementType='M' AND ce.CostingMethod='I') and st.ad_org_id = C.Ad_Org_ID and c.M_CostType_ID=acct.M_CostType_ID
WHERE
    st.isstocked = 'Y'
AND
    st.IsSold = 'Y'
AND
    w.lbr_WarehouseType='OWN'
AND
    w.IsInTransit = 'N'
GROUP BY
    produto
ORDER BY
    quantidade_disponivel desc
LIMIT 50
