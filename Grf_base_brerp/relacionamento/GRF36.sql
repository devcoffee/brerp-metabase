SELECT
    count(*) as quantidade_total,
    sum(case when o.isclosed = 'N' THEN 1 ELSE 0 END) as quantidade_andamento,
    sum(case when o.isclosed = 'Y' AND ss.IsWon = 'Y' THEN 1 ELSE 0 END) as quantidade_convertida,
    sum(case when o.isclosed = 'Y' AND ss.IsWon = 'N' THEN 1 ELSE 0 END) as quantidade_perdida
FROM
    C_Opportunity o
LEFT JOIN
    C_SalesStage ss ON ss.C_SalesStage_ID = o.C_SalesStage_ID
