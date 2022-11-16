SELECT 
    ms.name as segmento, 
    count(*) AS quantidade
FROM 
    AD_User l
LEFT JOIN 
    COF_C_MarketSegment ms ON ms.COF_C_MarketSegment_ID = l.COF_C_MarketSegment_ID
WHERE 
    l.IsSalesLead = 'Y'
AND
    l.IsActive = 'Y' 
AND
    l.LeadStatus NOT IN ('E')
GROUP BY
    segmento
ORDER BY 
    quantidade DESC
