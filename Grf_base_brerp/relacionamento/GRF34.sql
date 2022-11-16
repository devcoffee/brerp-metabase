SELECT 
    status, representante, COUNT(AD_User_ID) as qtd
FROM 
(
    SELECT
        'Ativas' as status,
        rep.name as representante,
        l.AD_User_ID,
        l.created as data
    FROM
        AD_User l 
    RIGHT OUTER JOIN
        AD_User rep ON rep.AD_User_ID = l.SalesRep_ID
    WHERE
        l.IsActive = 'Y'
    AND
        l.LeadStatus NOT IN ('E','C')
    
    UNION 
    
    SELECT
        'Convertidas' as Status,
        rep.name as representante,
        l.AD_User_ID,
        l.created as data
    FROM
        AD_User l 
    RIGHT OUTER JOIN
        AD_User rep ON rep.AD_User_ID = l.SalesRep_ID
    WHERE
        l.IsActive = 'Y'
    AND
        l.LeadStatus IN ('C')
) as leads
WHERE
    leads.data > now() - INTERVAL '12 months'
AND
    leads.data <= date_trunc('month', CURRENT_DATE)
GROUP BY
    leads.representante, leads.status
ORDER BY
    leads.representante, leads.status
